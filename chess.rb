require "./chess_pieces.rb"
require "./chess_player.rb"

class Chess

  # MZ: 31337
  UNICODE_CHARS = {
    "whiteKing" => "\u2654",
    "whiteQueen" => "\u2655",
    "whiteRook" => "\u2656",
    "whiteBishop" => "\u2657",
    "whiteKnight" => "\u2658",
    "whitePawn" => "\u2659",
    "blackKing" => "\u265A",
    "blackQueen" => "\u265B",
    "blackRook" => "\u265C",
    "blackBishop" => "\u265D",
    "blackKnight" => "\u265E",
    "blackPawn" => "\u265F"
  }

  attr_reader :board

  def initialize
    @board = []
    build_board
    populate_board
    # MZ: If you use a symbol for these, Ruby will keep 1 reference to the symbol in memory instead of instantiating
    # a throw-away-string object each time you do a comparison, initialization, etc
    # I'm sure it's not really a big deal for our purposes, but just an FYI.
    # http://www.troubleshooters.com/codecorn/ruby/symbols.htm#_What_are_the_advantages_and_disadvantages_of_symbols
    @player1 = Player.new("white")
    @player2 = Player.new("black")
    @current_player = @player1
  end

  def play
    #play the game until checkmate/victory

    until game_over?
      puts "It's your turn, #{@current_player.color} Player!"
      start_coord = []
      end_coord = []

      until start_coord_valid?(start_coord)
        puts "Start coordinates"
        start_coord = @current_player.get_location
      end
      puts "Move #{@board[start_coord[0]][start_coord[1]].class.to_s.upcase} where?"

      until valid_move?(start_coord, end_coord)
        puts "End coordinates"
        end_coord = @current_player.get_location
        p "End Coords: #{end_coord.inspect}"
      end

      execute_move(start_coord, end_coord)
      toggle_current_player
      print_board
    end
  end

  # MZ: Alternate way to build the board could be:
  # 
  # def build_board
  #   8.times { @board << Array.new(8) }
  # end
  #
  # The Array.new constructor can take a number of starting elements
  # and optionally a default value for them.... so like 
  # ` Array.new(8, nil)` would work too, or in our case: ` Array.new(8, :blank)` 
  #

  def build_board
    8.times do
      tmp = []
      8.times do
        tmp << nil
      end
      @board << tmp
    end
  end

  def populate_board
    @board[0], @board[1] = populate_side("white")

    black_setup = populate_side("black")
    @board[7], @board[6] = black_setup[0].reverse, black_setup[1]
    nil
    # create and put pieces in appropriate positions
    #pieces for black & white
  end

  def populate_side(color)
    first_row = [
      Rook.new(color),
      Knight.new(color),
      Bishop.new(color),
      King.new(color),
      Queen.new(color),
      Bishop.new(color),
      Knight.new(color),
      Rook.new(color)
    ]
    second_row = []
    8.times { second_row << Pawn.new(color) }
    [first_row, second_row]
  end

  def print_board
    # cycle through the board, outputting " * " for nil and unicode for each piece otherwise
    print "  "
    ("A".."H").each { |char| print " #{char} " }
    puts
    8.times do |row|
      print "#{row} "
      8.times do |col|
        piece = @board[row][col]
        if piece.nil?
          print " * "
        else
          print " #{UNICODE_CHARS[piece.name]} "
        end
      end
      puts
    end
    puts
  end

  def execute_move(from_coord, to_coord)
    @board[to_coord[0]][to_coord[1]] = @board[from_coord[0]][from_coord[1]]
    @board[from_coord[0]][from_coord[1]] = nil
  end

  def start_coord_valid?(coordinates)
    return false if coordinates.size == 0

    # No stupid stuff... is it my piece?
    piece = @board[coordinates[0]][coordinates[1]]

    if piece.nil?
      puts "NO PEACE \u262E"
      return false
    elsif piece.color != @current_player.color
      puts "Not yo' color!"
      return false
    else
      true
    end
  end

  def valid_move?(start_coords, end_coords)
    return false if end_coords.size == 0

    piece = @board[start_coords[0]][start_coords[1]]
    # Ask peace for its theoretical moves
    if piece.is_a?(Pawn)
      theoretical_moves = piece.theoretical_moves(start_coords[0], start_coords[1], @board)
    else
      theoretical_moves = piece.theoretical_moves(start_coords[0], start_coords[1])
    end
    p "Theoreticals: #{theoretical_moves.inspect}"
    # is the end point included in them at all
    #if so, make new array with just that one
    move_seq = theoretical_moves.select { |sub_a| sub_a.include?(end_coords) }.first
    return false if move_seq.nil?

    move_seq.each do |tile_coords|
      tile = @board[tile_coords[0]][tile_coords[1]]
      if tile_coords == end_coords
        if tile.nil?
          return true
        elsif tile.color != @current_player.color
          return true
        else
          return false
        end
      elsif !tile.nil?
        return false
      end
    end
  end

  def toggle_current_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def game_over?
    false
  end

end

# NOTES
# Infinite loop if choosing piece with no possible moves
# Check
# Checkmate
  # Danger ZOOOOOOOONE!!!!
# simple commands, eg. quit, save, change piece




# SCRIPT

c = Chess.new
c.populate_board
c.print_board
c.play

#puts "OUTPUT: #{c.board[0][1].theoretical_moves(0, 1)}"