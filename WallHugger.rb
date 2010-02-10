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
    
    puts "Valid Moves:"
    p valid_moves
    
    case valid_moves.size
      when 0
        move = :NORTH
      when 1
        move = valid_moves[0]
      else
        move = weighted_choices(valid_moves, map)
    end
    
    puts "Moving: #{move}"
    map.make_move( move )
  end
  
  def wall_hug(valid_moves, map)
    possible_moves = []

    valid_moves.each do |direction|
      puts "Testing: #{direction}"
      dest = map.rel(direction)
      adjacents = map.adjacent(dest)
      p adjacents
      wall_count = adjacents.inject(0) { |count, pos| map.wall?(pos) ? count + 1 : count }
      if (wall_count != 4)
        adjacents.each do |position|
          puts "Checking #{position[0]}, #{position[1]}"
          if map.wall?(position)
            possible_moves << direction
            puts "^- Possible Choice"
          end
        end
      else
        puts "That would have been a bad move."
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
    puts "Weight Group:"
    p weight_group
    puts "Possible Moves:"
    p possible_moves
    
    possible_moves = valid_moves if possible_moves.size == 0
    possible_moves[rand(possible_moves.size)]
  end
  
  def evaluate_move(move, map)
    adjacents  = map.adjacent(move)
    wall_count = adjacents.inject(0) { |count, pos| map.wall?(pos) ? count + 1 : count }
    if (wall_count == 4)
      0
    else
      flood_count(move, map)
    end
  end
  
  def flood_count(move, map)
    temp_walls = map.get_walls
    width = map.width
    height = map.height
    
    fill_queue = []
    fill_count = 1
    
    fill_queue << move
    
    fill_queue.each do |pos|
      p fill_queue
      fill_string(temp_walls, height, width)
      x, y = pos
      temp_walls[x * width + y] = true
      map.adjacent(move).each do |adj|
        x, y = adj
        puts "Checking(#{x},#{y}) : #{!temp_walls[x * width + y]}"
        if (!temp_walls[x * width + y])
          fill_queue << adj
        end
      end
    end
    fill_count   
  end
  
 def fill_string(map, height, width)

      out = ""
      counter = 0
              
      height.times do
          width.times do
              out += map[counter] == true ? "#" : "-"
              counter+=1
          end
          out += "\n"
      end
      
      
      puts out
      
  end
  
  def initialize
    while(true)
      map = Map.new()
      makemove(map)
    end
  end
	
end

TronBot.new()
