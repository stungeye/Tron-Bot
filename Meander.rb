# wallHugger
# Author: Wally Glutton
# http://stungeye.com

require "map.rb"
require "printing.rb"

#NB: This AI communicates with the contest engine over
#standard out. printing.rb contains convenience methods
#which overload the puts, p and print methods such that
#they output to standard error instead.

class TronBot

  def makemove(map)
    valid_moves = map.valid_moves
    
    #puts "Valid Moves:"
    #p valid_moves
    
    case valid_moves.size
      when 0
        move = :NORTH
      when 1
        move = valid_moves[0]
      else
        move = weighted_choices(valid_moves, map)
    end
    
    #puts "Moving: #{move}"
    map.make_move( move )
  end
  
  def wall_hug(valid_moves, map)
    possible_moves = []

    valid_moves.each do |direction|
      dest = map.rel(direction)
      adjacents = map.adjacent(dest)
      wall_count = adjacents.inject(0) { |count, pos| map.wall?(pos) ? count + 1 : count }
      if (wall_count != 4)
        adjacents.each do |position|
          if map.wall?(position)
            possible_moves << direction
          end
        end
      end
    end
    
    possible_moves = valid_moves if possible_moves.size == 0
    possible_moves[rand(possible_moves.size)]
  end
  
  def weighted_choices(valid_moves, map)
    weight_group = {}
    possible_moves = []
    highest_weight = -1

    valid_moves.each do |direction|
      dest = map.rel(direction)
      weight = evaluate_move(dest, map)
      weight_group[direction] = weight
      if (weight > highest_weight)
        highest_weight = weight
        possible_moves = [direction]
      elsif (weight == highest_weight)
        possible_moves << direction
      end
    end
    
    possible_moves = valid_moves if possible_moves.size == 0
    possible_moves[rand(possible_moves.size)]
  end
  
  def evaluate_move(move, map)
    adjacents  = map.adjacent(move)
    4 - adjacents.inject(0) { |count, pos| map.wall?(pos) ? count + 1 : count }
  end
    
  def initialize
    while(true)
      map = Map.new()
      makemove(map)
    end
  end
	
end

TronBot.new()
