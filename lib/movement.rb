# frozen_string_literal: true

# lib/movement.rb

require_relative 'chess'
require_relative 'board'
require_relative 'cell'
require_relative 'piece'
require_relative 'pieces/all_pieces'

class Movement
  def initialize(game)
    @board = game.board
    @game = game
  end

  def legal_moves(cell)
    return [] if cell.empty?

    piece = cell.piece
    psuedo = piece.moves(@board, cell.name)
    king = piece.is_a?(King) ? cell : active_king
    attackers, enemies = get_enemies(king)
    danger_zone = dangers(king)
    no_go_zone = attacks(king)
    return king_helper(psuedo, cell, danger_zone, no_go_zone) if piece.is_a?(King)

    if danger_zone.include?(king)
      return [] if attackers.length > 1 # Double check, only King has moves

      results = []
      enemy_cell = attackers.pop
      return [enemy_cell.name] if psuedo.include?(enemy_cell)

      # Test block available?

      results.map(&:name).sort
    else
      enemies.length
      psuedo.map(&:name).sort
    end
  end

  def get_enemies(king)
    attackers = []
    enemies = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        if cell.piece.moves(@board, cell.name).include?(king)
          attackers << cell
        else
          enemies << cell
        end
      end
    end
    [attackers, enemies]
  end

  def dangers(king)
    # Based on all_paths
    result = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        result << cell.piece.captures(@board, cell.name)
      end
    end

    result.flatten.uniq
  end

  def attacks(king)
    result = []
    @board.data.each do |rank|
      rank.each do |cell|
        next if cell.empty? || king.friendly?(cell)

        to_add = cell.piece.is_a?(Pawn) ? cell.piece.captures(@board, cell.name) : cell.piece.moves(@board, cell.name)
        result << to_add
      end
    end
  end

  private

  def active_king
    @game.active == 'w' ? @board.wking : @board.bking
  end

  def king_helper(psuedo, origin, danger_zone, attacks)
    # Find the difference between danger_zone and attacks
    to_test = danger_zone - attacks

    # Test each move to determine if legal
    to_test.each do |destination|
      game_deep_copy = Marshal.load(Marshal.dump(@game))
      psuedo - destination unless move_legal?(game_deep_copy, origin, destination)
    end

    # Remove other squares under attack.
    (psuedo - attacks).uniq.map(&:name).sort
  end

  def move_legal?(game, origin, destination)
    moves_manager = new(game)
    game.move_piece(origin, destination)
    attackers, = moves_manager.get_enemies(king)
    attackers.empty?
  end
end
