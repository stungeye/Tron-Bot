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
    #puts "Opponent Unreachable: #{map.opponent_unreachable}"
    #puts "Moving: #{move}"
    map.make_move( move )
  end
 
  def weighted_choices(valid_moves, map)
    weight_group = {}
    possible_moves = []
    highest_weight = -1

    
    valid_moves.each do |direction|
      dest = map.rel(direction)
      weight = map.fill_count(dest)
      weight_group[direction] = weight
      if (weight > highest_weight)
        highest_weight = weight
        possible_moves = [direction]
      elsif (weight == highest_weight)
        possible_moves << direction
      end
    end
    
    possible_moves = valid_moves if possible_moves.size == 0
    if (map.opponent_unreachable)
      possible_moves[0]
    else
      possible_moves[rand(possible_moves.size)]
    end
  end
  
  
  def initialize
    while(true)
      map = Map.new()
      makemove(map)
    end
  end
	
end

TronBot.new()
