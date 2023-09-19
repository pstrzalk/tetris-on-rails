class Game < ApplicationRecord
  TooManyBricks = Class.new(StandardError)
  IvalidAction = Class.new(StandardError)

  BOARD_WIDTH = 8
  BOARD_HEIGHT = 11

  EMPTY_BOARD_CELL = ' '.freeze
  FULL_BOARD_CELL  = 'x'.freeze
  BRICK_BOARD_CELL = ':'.freeze

  DEFAULT_BOARD = [[EMPTY_BOARD_CELL] * BOARD_WIDTH] * BOARD_HEIGHT

  QUESTION_VISIBILITY_TIME = 100
  QUESTION_ANSWER_VISIBILITY_TIME = 20

  QUESTIONS = {
    '0001' => Question.new('falsy', 'nil', ['""', '0', 'nil']),
    '0002' => Question.new('falsy', 'false', ['false', '[ ]', '0']),
    # There were more questions :)
}.freeze

  broadcasts_to ->(game) { "game_#{game.id}" }

  has_one :timer
  accepts_nested_attributes_for :timer

  delegate :tick, :question_tick, to: :timer
  delegate 'tick=', 'question_tick=', to: :timer

  def self.build_for_player(player_id)
    new(
      player_id: player_id,
      score: 0,
      actions: [],
      board: DEFAULT_BOARD,
      brick_position_x: nil,
      brick_position_y: nil,
      brick_shape: nil,
      brick_rotated_times: nil,
      next_brick_shape: nil,
    ).tap do |g|
      g.build_timer
    end
  end

  def brick
    return nil unless brick_shape

    Brick.new(brick_shape, brick_position_x, brick_position_y, brick_rotated_times)
  end

  def next_brick
    return nil unless next_brick_shape

    Brick.new(next_brick_shape)
  end

  def spawn_brick
    raise TooManyBricks if brick

    self.brick_shape = next_brick_shape || Brick::SHAPES.sample
    self.brick_position_x = 3
    self.brick_position_y = 0
    self.brick_rotated_times = 0
    self.next_brick_shape = Brick::SHAPES.sample

    self.running = false if brick_collides?(brick)
  end

  def brick_collides?(some_brick)
    return true if some_brick.position_x + some_brick.width > BOARD_WIDTH
    return true if some_brick.position_y + some_brick.height > BOARD_HEIGHT

    brick_collides = false

    some_brick.body.each_with_index do |line, row_index|
      line.each_with_index do |element, column_index|
        next if brick_collides
        next unless element == Brick::FULL_CELL

        brick_collides = board[some_brick.position_y + row_index][some_brick.position_x + column_index] == FULL_BOARD_CELL
      end
    end

    brick_collides
  end

  def register_action(action)
    raise(IvalidAction, action) unless Action::ALL.include?(action)

    actions << action
  end

  def perform_action(action)
    return unless brick

    case action
    when Action::MOVE_LEFT
      return if brick.position_x <= 0

      brick_when_moved_left = brick.dup
      brick_when_moved_left.position_x -= 1
      return if brick_collides?(brick_when_moved_left)

      self.brick_position_x -= 1
    when Action::MOVE_RIGHT
      return if brick.position_x + brick.width >= BOARD_WIDTH

      brick_when_moved_right = brick.dup
      brick_when_moved_right.position_x += 1
      return if brick_collides?(brick_when_moved_right)

      self.brick_position_x += 1
    when Action::ROTATE
      self.brick_rotated_times += 1
      if brick_collides?(brick)
        self.brick_position_x -= 1
        if brick_collides?(brick)
          self.brick_position_x += 2

          if brick_collides?(brick)
            self.brick_rotated_times -= 1
            self.brick_position_x -= 1
          end
        end
      end

      if self.brick_rotated_times == 4
        self.brick_rotated_times = 0
      end
    end
  end

  def perform_registered_actions
    actions.each { |action| perform_action(action) }

    self.actions = []
  end

  def apply_gravity
    return unless running

    hit_ground = false

    if brick
      brick.body.each_with_index do |line, row_index|
        next if hit_ground

        hit_ground = brick_position_y + row_index + 1 == BOARD_HEIGHT
        line.each_with_index do |element, column_index|
          next if hit_ground
          next unless element == Brick::FULL_CELL

          hit_ground = board[brick_position_y + row_index + 1][brick_position_x + column_index] == FULL_BOARD_CELL
        end
      end

      if hit_ground
        brick.body.each_with_index do |line, row_index|
          line.each_with_index do |element, column_index|
            next unless element == Brick::FULL_CELL

            board[brick_position_y + row_index][brick_position_x + column_index] = FULL_BOARD_CELL
          end
        end

        self.brick_shape = nil
        self.brick_position_x = nil
        self.brick_position_y = nil
        self.brick_rotated_times = nil
      else
        self.brick_position_y += 1
      end
    end
  end

  def handle_full_lines
    return if brick

    full_line_indexes = []
    board.each_with_index do |line, row_index|
      if line.all?(Game::FULL_BOARD_CELL)
        full_line_indexes << row_index
      end
    end

    full_line_indexes.reverse.each do |index|
      board.delete_at(index)
    end

    number_of_cleared_lines = full_line_indexes.size

    if number_of_cleared_lines > 0
      self.board = [[EMPTY_BOARD_CELL] * BOARD_WIDTH] * number_of_cleared_lines + board
      self.score += score_per_number_of_lines(number_of_cleared_lines)
    end

    if number_of_cleared_lines > 1
      ask_question
    else
      spawn_brick
    end
  end

  def score_per_number_of_lines(count)
    case count
    when 0 then 0
    when 1 then 10
    when 2 then 25
    when 3 then 50
    when 4 then 100
    else
      0
    end
  end

  def question
    return nil unless question_id.present?

    QUESTIONS[question_id]
  end

  def ask_question
    self.question_id = QUESTIONS.keys.sample
    self.question_result = nil
    self.question_tick = 0
  end

  def answer(answer_text)
    return nil unless question

    if question.correct_answer == answer_text
      self.score += 25
      self.question_result = "Correct, we've added 25 points to your score!"
    else
      self.question_result = "Incorrect, better luck next time..."
    end

    self.question_tick = 0
    self.question_id = nil
  end

  def abandon_question
    self.question_id = nil
    self.question_tick = 0
    self.question_result = "Sorry, you've missed your chance."
  end
end
