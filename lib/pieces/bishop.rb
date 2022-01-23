# frozen_string_literal: true

# lib/pieces/bishop.rb

class Bishop < Piece
  def moves(board, origin)
    moves = []
    # Clockwise from north @ 12
    offsets = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    offsets.each { |offset| moves << Move.new(board, origin, offset) }
    moves.reject(&:dead?) # Remove empty moves
  end

  def slides?
    true
  end
end
