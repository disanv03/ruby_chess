# frozen_string_literal: true

# lib/castle.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'piece'
require_relative 'movement'
require_relative 'pieces/all_pieces'


class Castle
  def initialize(game)
    @game = game
    @board = game.board
  end

  def update_rights(game, piece, cell)
    return unless piece.is_a?(King) || piece.is_a?(Rook)
  
    rights = game.castle.dup
    delete_rights = 'KQ'
    delete_rights.downcase if piece.black?
    if piece.is_a?(Rook)
      king_side = piece.white? ? cell.name > 'e' : cell.name < 'e'
      king_side ? rights.delete!(delete_rights[0]) : rights.delete!(delete_rights[1])
    else
      rights.delete!(delete_rights)
    end
    rights = '-' if rights.empty?
    game.castle = rights
  end
end