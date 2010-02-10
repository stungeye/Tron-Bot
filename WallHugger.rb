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
    x, y = map.my_position
    
    valid_moves = []
    valid_moves << :NORTH if not map.wall?([x, y-1])
    valid_moves << :SOUTH if not map.wall?([x, y+1])
    valid_moves << :WEST  if not map.wall?([x-1, y])
    valid_moves << :EAST  if not map.wall?([x+1, y])
    
    case valid_moves.size
      when 0
        move = :NORTH
      when 1
        move = valid_moves[0]
      else
        move = wall_hug(valid_moves, map)
    end
    
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
  
  def initialize
    while(true)
      map = Map.new()
      makemove(map)
    end
  end
	
end

TronBot.new()
