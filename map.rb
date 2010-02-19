# The Map class gets the Tron map from the game engine, and provides some
# methods that allow you to look at it.
#
# You should not change any of the code in this file. It's just here for
# your convenience, to do the boring parts for you.
#
# Copied from the Java example

class Map

  InvalidMove = Class.new(StandardError)
  attr_reader :width, :height, :my_position, :opponent_position
  DIRECTIONS = [:NORTH, :EAST, :SOUTH, :WEST]
  
  def initialize()
		@width = -1
		@height = -1
		@walls = []
		@my_position = [-1,-1]
		@opponent_position = [-1,-1]
		read_map
  end	
  
  def read_map
  
		begin
			#read the width and height from the first line
			firstline = $stdin.readline("\n")
			width, height = firstline.split(" ")
			@width = width.to_i
			@height = height.to_i
			
			#check for properly formatted width, height
			if height == 0 or width == 0
				p "OOPS!: invalid map dimensions: " + firstline
				exit(1)
			end
			
			#read the representation of the board
			lines = []
			@height.times do
				#lines += [$stdin.readline("\n").strip]
				lines += [$stdin.readline("\n").chomp]
			end
			board = lines.join("")
			
			#get the wall data
			@walls = board.split(//).map{|char| char == " " ? false : true}
			
			#get player starting locations
			p1start = board.index("1").to_i
			p2start = board.index("2").to_i
			
			if board.split(//).select{|char| char == "1"}.size > 1
				p "OOPS!: found more than 1 location for player 1"
				exit(1)
			end
			
			if board.split(//).select{|char| char == "2"}.size > 1
				p "OOPS!: found more than 1 location for player 2"
				exit(1)
			end
			
			p "OOPS!: Cannot find locations." if p1start == nil or p2start == nil
			
			pstartx = p1start % @width
			pstarty = (p1start / @width)
			@my_position = [pstartx, pstarty]
			
			pstartx = p2start % @width
			pstarty = (p2start / @width)
			@opponent_position = [pstartx, pstarty]
		rescue EOFError => e
			# Got EOF: tournament is finished.
			exit(0)
		rescue => e
			p  e
			exit(1)
		end
  
  end
  private :read_map
  
  def each(&proc)
		(0..@height-1).each{|y|
			(0..@width-1).each{|x|
				proc[x, y, wall?([x, y])]
			}
		}
  end
  
  def wall? (coordinates, walls = @walls)
		x, y = coordinates
		return true if x < 0 or y < 0 or x >= @width or y >= @height
		return walls[x+@width*y]
  end
  
  def to_string()
		out = ""
		counter = 0
						
		@height.times do
			@width.times do
				out += @walls[counter] == true ? "#" : "-"
				counter+=1
			end
			out += "\n"
		end
		
		return out
  end
  
  def make_move(direction)
		$stdout << ({:NORTH=>1, :SOUTH=>3, :EAST=>2, :WEST=>4}[direction])
		$stdout << "\n"
		$stdout.flush
  end
  
  def get_walls
    @walls
  end
	
  def rel(direction, origin = nil)
    origin = @my_position if origin.nil?
    x, y   = origin
    
    case direction
      when :NORTH
        [x, y - 1]
      when :SOUTH
        [x, y + 1]
      when :EAST
        [x + 1, y]
      when :WEST
        [x - 1, y]
      else
        raise InvalidMove;
    end
  end
  
  def adjacent(origin)
    DIRECTIONS.inject([]) { |adjacents, direction| adjacents << rel(direction, origin) }
  end
  
  def valid_moves(origin = nil)
    origin = @my_position if origin.nil?
    x, y   = origin
    
    valid_moves = []
    valid_moves << :NORTH if not wall?([x, y-1])
    valid_moves << :SOUTH if not wall?([x, y+1])
    valid_moves << :EAST  if not wall?([x+1, y])
    valid_moves << :WEST  if not wall?([x-1, y])
    valid_moves
  end
  
  def distance_from_opponent(origin = nil)
    origin = @my_position if origin.nil?
    my_x, my_y   = origin
    opp_x, opp_y = @opponent_position
    (my_x - opp_x)**2 + (my_y - opp_y)**2
  end
  
  def flood_fill(move, walls)
    if wall?(move, walls)
      0
    else
      x, y = move
      walls[x + @width * y] = true
      adj = adjacent(move)
      return 1 +
        flood_fill(adj[0], walls) + 
        flood_fill(adj[1], walls) + 
        flood_fill(adj[2], walls) + 
        flood_fill(adj[3], walls)
    end
  end
  
  def fill_count(move)
    temp_walls = @walls.dup
    flood_fill(move, temp_walls)
  end
  
  def look_ahead_fill_count(direction)
		temp_walls = @walls.dup
		move = rel(direction)
		i = 0
		#while (!wall?(rel(direction, move), temp_walls))
		while !wall?(move, temp_walls) && i < 3
			x, y = move
			temp_walls[x + @width * y] = true
			move = rel(direction, move)
			i += 1
		end
		#fill_string(temp_walls, @height, @width)
		x, y = move
		temp_walls[x + @width * y] = false
		
		score = flood_fill(move, temp_walls) + i
		score
  end
  
  def solo_maximax(walls, current_position, max_depth, current_depth )
		#if (current_depth == 1)
		#	puts "Evaluating #{current_position[0]}, #{current_position[1]}"
		#end
		if wall?(current_position, walls)
			[-100, current_position]
		elsif (current_depth == max_depth) 
			new_walls = walls.dup
			#puts "Leaf #{current_position[0]},#{current_position[1]} Position: "
			#fill_string(new_walls, @height, @width)
			score = flood_fill(current_position, new_walls)
			#puts "Position: #{current_position[0]},#{current_position[1]} Score: #{score}"
			[score, current_position]
		else
			valid_moves = valid_moves(current_position)
			return [-100, current_position] if valid_moves.size == 0
			best_move = nil
			best_score = -1000
			valid_moves.each do |possible_direction|
				new_walls = walls.dup
				x, y = current_position
				new_walls[x + @width * y] = true
				possible_move = rel(possible_direction, current_position)
				current_score, current_move = solo_maximax(new_walls, possible_move, max_depth, current_depth + 1)
				if current_score > best_score
					best_score = current_score
					best_move = possible_move
				end
			end
			
			[best_score, best_move]
		end
  end
  
  def best_solo_move()
		temp_walls = @walls.dup
		x, y = @my_position
		#puts "At position: #{x},#{y}"
		temp_walls[x + @width * y] = false
		score, move = solo_maximax(temp_walls, @my_position, 4, 0)
		#p move
		#puts "Selected: #{move[0]}, #{move[1]}"
		valid_moves(@my_position).each do |direction|
			current_move = rel(direction)
			if (move[0] == current_move[0]) && (move[1] == current_move[1])
				return direction
			end
		end
  end
  
  def opponent_search(move, walls)
    if wall?(move, walls)
      opponent?(move)
    else
      x, y = move
      walls[x + @width * y] = true
      adj = adjacent(move)
      return opponent?(move) ||
        opponent_search(adj[0], walls) ||
        opponent_search(adj[1], walls) ||
        opponent_search(adj[2], walls) ||
        opponent_search(adj[3], walls)
    end
  end
  
  def opponent_unreachable?
		temp_walls = @walls.dup
		x, y = @my_position
		temp_walls[x + @width * y] = false
		!opponent_search(@my_position, temp_walls)
	end
  
  def opponent?(position)
    (position[0] == @opponent_position[0]) && (position[1] == @opponent_position[1])
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
  
end
