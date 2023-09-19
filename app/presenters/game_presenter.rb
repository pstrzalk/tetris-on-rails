class GamePresenter
  def initialize(game)
    @game = game
  end

  def board_with_brick
    board = @game.board.dup

    brick = @game.brick
    return board unless brick

    brick.body.each_with_index do |line, row_index|
      line.each_with_index do |element, column_index|
        next unless element

        board[brick.position_y + row_index][brick.position_x + column_index] = Game::BRICK_BOARD_CELL
      end
    end

    board
  end

  def to_s
    board_with_brick.map(&:join).join("\n")
  end
end
