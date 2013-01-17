# Adam and Erik
# 1/16/13

class Piece
#ask ned about way to change attrs to attr?
  BOARD_LENGTH = 8
  DIAGONALS = [[-1,-1],[-1,1],[1,1],[1,-1]]
  LEFT_RIGHT = [[1,0],[-1,0]]
  FWD_BACK = [[0,1],[0,-1]]
  KNIGHT = [[-2,1],[-2,-1],[-1,2],[-1,-2],[1,2],[1,-2],[2,1],[2,-1]]

  attr_accessor :moved
  attr_reader :color

  alias_method :moved?, :moved # MZ: nice

  def initialize(color)
    @color = color
    @moved = false
  end

  def name
    @color + self.class.to_s
  end

  def in_bounds?(coordinates)
    coordinates.all? { |coord| (0..BOARD_LENGTH-1).include?(coord) }
  end

#outputs an array containing subarrays of theoretical moves (in order outwards)
  def theoretical_moves(start_row, start_column)
    theoretical_moves = []

    self.moves.each do |move_coord|
      row, column = start_row, start_column
      move_chain = []
      while in_bounds?([row + move_coord[0], column + move_coord[1]]) && move_chain.size < self.max_distance
        move_chain << [row + move_coord[0], column + move_coord[1]]
        row += move_coord[0]
        column += move_coord[1]
      end
      theoretical_moves << move_chain
    end
    theoretical_moves
  end

end

# ------------------------------------------------------------------------------

class King < Piece
  # MZ: This stuff doesn't need to be in each sub class.  If you add it to the super class, sub classes get it for free.
  attr_reader :moves, :max_distance 

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK + DIAGONALS
    @max_distance = 1
  end
end

class Queen < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK + DIAGONALS
    @max_distance = 8
  end
end

class Rook < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = LEFT_RIGHT + FWD_BACK
    @max_distance = 8
  end
end

class Bishop < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = DIAGONALS
    @max_distance = 8
  end
end

class Knight < Piece
  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
    @moves = KNIGHT
    @max_distance = 1
  end
end

class Pawn < Piece

  attr_reader :moves, :max_distance

  def initialize(color)
    super(color)
  end

  # Returns the pawn's possible moves, excluding moves that illegally interfere
  # with existing or enemy pieces
  def theoretical_moves(start_row, start_column, board)
    moves = []#crazy logic going on here.
    # MZ: "Fuck Pawns." -Sean Kim, January 16th, 2013
    if self.color == "white" # MZ: per ned's comments in today's lecture/questions, it looks like we should not be using the "self" calls
      moves << [[start_row + 1, start_column]] if board[start_row + 1][start_column].nil?
      if !moved? && board[start_row + 1][start_column].nil? && board[start_row + 2][start_column].nil?
        moves << [[start_row + 1, start_column], [start_row + 2, start_column]]
      end
      if !board[start_row + 1][start_column + 1].nil?
        moves << [[start_row + 1,start_column + 1]]
      elsif !board[start_row + 1][start_column - 1].nil?
        moves << [[start_row + 1][start_column - 1]]
      end

    elsif self.color == "black"
      moves << [[start_row - 1, start_column]] if board[start_row - 1][start_column].nil?
      if !moved? && board[start_row - 1][start_column].nil? && board[start_row - 2][start_column].nil?
        moves << [[start_row - 1, start_column], [start_row - 2, start_column]]
      end
      if !board[start_row - 1][start_column + 1].nil?
        moves << [[start_row - 1,start_column + 1]]
      elsif !board[start_row - 1][start_column - 1].nil?
        moves << [[start_row - 1][start_column - 1]]
      end
    end
    moves
  end
end






