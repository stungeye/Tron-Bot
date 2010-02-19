# Survival Look Ahead
# Author: Wally Glutton
# http://stungeye.com

#require "time"
require "map.rb"
require "printing.rb"
require "array.rb"

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
        move = select_best_move(valid_moves, map)
    end
    #puts "Opponent Unreachable: #{map.opponent_unreachable}"
    #puts "Moving: #{move}"
    map.make_move( move )
  end
  
  def select_best_move(valid_moves, map)
    space_optimizing_moves = valid_moves.select_largest { |move| map.fill_count(map.rel(move)) }    
    if map.opponent_unreachable?
			return map.best_solo_move
			#selected_moves = space_optimizing_moves #.select_largest { |move| map.look_ahead_fill_count(move) }
			#return selected_moves[0]
    elsif map.distance_from_opponent < 16
			selected_moves = space_optimizing_moves
    else
			selected_moves = space_optimizing_moves.select_smallest { |move| map.distance_from_opponent(map.rel(move)) }
    end
    selected_moves = valid_moves if selected_moves.size == 0
    selected_moves[rand(selected_moves.size)]
  end
  
  
  def initialize
    while(true)
      map = Map.new()
      #start_time = Time.now
      makemove(map)
      #end_time = Time.now
      #puts "New Move Took: " + (end_time - start_time).to_s
    end
  end
	
end

TronBot.new()
