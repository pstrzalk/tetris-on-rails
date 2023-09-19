class Brick
  UnknownShape = Class.new(StandardError)

  attr_accessor :shape, :position_x, :position_y, :rotated

  BLANK_CELL = false
  FULL_CELL = true

  EL = 'el'.freeze
  LE = 'le'.freeze
  ES = 'es'.freeze
  LINE = 'line'.freeze
  SQUARE = 'square'.freeze
  KCROSS = 'kcross'.freeze

  SHAPES = [LINE, SQUARE, KCROSS, EL, LE, ES].freeze

  def initialize(shape, position_x = 0, position_y = 0, rotated_times = 0)
    @shape = shape
    @position_x = position_x
    @position_y = position_y
    @rotated_times = rotated_times
  end

  def body
    base_body = case shape
                when EL
                  [
                    [BLANK_CELL, BLANK_CELL, FULL_CELL],
                    [FULL_CELL, FULL_CELL, FULL_CELL]
                  ]
                when LE
                  [
                    [FULL_CELL, BLANK_CELL, BLANK_CELL],
                    [FULL_CELL, FULL_CELL, FULL_CELL]
                  ]
                when ES
                  [
                    [BLANK_CELL, FULL_CELL, FULL_CELL],
                    [FULL_CELL, FULL_CELL, BLANK_CELL]
                  ]
                when LINE
                  [
                    [FULL_CELL, FULL_CELL, FULL_CELL, FULL_CELL]
                  ]
                when SQUARE
                  [
                    [FULL_CELL, FULL_CELL],
                    [FULL_CELL, FULL_CELL]
                  ]
                when KCROSS
                  [
                    [FULL_CELL, FULL_CELL, FULL_CELL],
                    [BLANK_CELL, FULL_CELL, BLANK_CELL]
                  ]
                else
                  raise UnknownShape, shape
                end

    @rotated_times.times do
      base_body = rotate(base_body)
    end

    base_body
  end

  def rotate(body_to_rotate)
    rotated_body = []

    body_to_rotate.reverse.each_with_index do |row, row_no|
      row.each_with_index do |cell, cell_no|
        rotated_body[cell_no] ||= []
        rotated_body[cell_no][row_no] = cell
      end
    end

    rotated_body
  end

  def height
    body.size
  end

  def width
    body.map(&:size).max
  end
end
