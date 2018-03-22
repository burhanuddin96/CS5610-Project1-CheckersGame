defmodule Checkers.Game do
	
	def game_after_player1_joins(username) do
		%{
      		p1: username,
      		p2: nil,
      		light_s: [],
      		light_k: [],
     		dark_s: [],
      		dark_k: [],
      		moves: [],
      		current_player: "P1",
      		checker_selected: -1,
      		jump: false,
      		game_state: "wait_p",
		}
	end

	def game_after_player2_joins(game, username) do
		%{
      		p1: game.p1,
      		p2: username,
      		light_s: game.light_s,
      		light_k: game.light_k,
     		dark_s: game.dark_s,
      		dark_k: game.dark_k,
      		moves: [],
      		current_player: "P1",
      		checker_selected: -1,
      		jump: false,
      		game_state: "wait_p",
		}
	end



	#############################################################################
	# handle click event on board
	# can click on a checker or a movement
        def click_checker_or_move(game, i) do
		cond do
			in_moves(game, i) -> click_move(game, i)
		  	in_checkers(game, i) -> click_checker(game, i)
			true -> game
		end
	end


	# check whether clicked position is in moves
	def in_moves(game, i) do
		Enum.any?(game.moves, fn(x) -> x == i end)
	end

	# check whether clicked position is in checkers
	def in_checkers(game, i) do
		in_light(game, i) or
		in_dark(game, i)
	end

	# checke whether clicked position is in light checkers
	def in_light(game, i) do
		in_light_s(game, i) or
		in_light_k(game, i)
	end

	# checker whether clicked position is in light single checkers
	def in_light_s(game, i) do
		Enum.any?(game.light_s, fn(x) -> x == i end)
	end

	# checker whether clicked position is in light king checkers
	def in_light_k(game, i) do
		Enum.any?(game.light_k, fn(x) -> x == i end)
	end

	# checke whether clicked position is in dark checkers
	def in_dark(game, i) do
		in_dark_s(game, i) or
		in_dark_k(game, i)
	end

	# checker whether clicked position is in dark single checkers
	def in_dark_s(game, i) do
		Enum.any?(game.dark_s, fn(x) -> x == i end)
	end

	# checker whether clicked position is in dark king checkers
	def in_dark_k(game, i) do
		Enum.any?(game.dark_k, fn(x) -> x == i end)
	end




	##############################################################################
	# handle click on a checker
     	def click_checker(game, i) do
		game = clear_moves(game)  # clear previous moves
		       |> add_jumps(i)
		game = if length(game.moves) == 0 do # can make regular moves only 
			 add_regular_moves(game, i)  # when there is no jump
		       else game
		       end
		Map.put(game, :checker_selected, i) # set selected checker
	end

	# clear moves in the given game
	def clear_moves(game) do
		Map.put(game, :moves, [])
	end

	# add jumps this checker can make
	def add_jumps(game, i) do
		cond do
			in_light_s(game, i) -> add_jump_light_s(game, i)
			in_light_k(game, i) -> add_jump_light_k(game, i)
			in_dark_s(game, i) -> add_jump_dark_s(game, i)
			in_dark_k(game, i) -> add_jump_dark_k(game, i)
		end
	end
	
	###########################################################################
	# add jumps when clicked light checker
	# add jumps this checker can make when clicked checker is a light_s
	def add_jump_light_s(game, i) do
		add_jump_light_left_top(game, i)
		|> add_jump_light_right_top(i)
	end

	# add jumps this checker can make when clicked checker is a light_k
	def add_jump_light_k(game, i) do
		add_jump_light_left_top(game, i)
		|> add_jump_light_right_top(i)
		|> add_jump_light_left_bottom(i)
		|> add_jump_light_right_bottom(i)
	end

        # add jump if clicked checker can jump towards left top direction
	def add_jump_light_left_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and in_dark(game, (x-1)*8+y-1) 
		   and in_boundary(x-2, y-2)  
		   and !in_checkers(game, (x-2)*8+y-2)do
			add_into_moves(game, (x-2)*8+y-2)
		end
	end

	# add jump if clicked checker can jump towards right top direction
	def add_jump_light_right_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and in_dark(game, (x+1)*8+y-1) 
		   and in_boundary(x+2, y-2)  
		   and !in_checkers(game, (x+2)*8+y-2)do
			add_into_moves(game, (x+2)*8+y-2)
		end
	end

        # add jump if clicked checker can jump towards left bottom direction
	def add_jump_light_left_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and in_dark(game, (x-1)*8+y+1) 
		   and in_boundary(x-2, y+2)  
		   and !in_checkers(game, (x-2)*8+y+2)do
			add_into_moves(game, (x-2)*8+y+2)
		end
	end

	# add jump if clicked checker can jump towards right bottom direction
	def add_jump_light_right_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and in_dark(game, (x+1)*8+y+1) 
		   and in_boundary(x+2, y+2)  
		   and !in_checkers(game, (x+2)*8+y+2)do
			add_into_moves(game, (x+2)*8+y+2)
		end
	end

	# check whether game position is in board's boundary
	def in_boundary(x,y) do
		x >= 0 and x <= 7 and y >= 0 and y <= 7
	end

	# add given position into moves of given game
	def add_into_moves(game, i) do
		moves = game.moves ++ [i]
		Map.put(game, :moves, moves)
	end

	###########################################################################
	# add jumps when clicked dark checker
	# add jumps this checker can make when clicked checker is a dark_s
	def add_jump_dark_s(game, i) do
		add_jump_dark_left_bottom(game, i)
		|> add_jump_dark_right_bottom(i)
	end

	# add jumps this checker can make when clicked checker is a dark_k
	def add_jump_dark_k(game, i) do
		add_jump_dark_left_top(game, i)
		|> add_jump_dark_right_top(i)
		|> add_jump_dark_left_bottom(i)
		|> add_jump_dark_right_bottom(i)
	end


 	# add jump if clicked checker can jump towards left top direction
	def add_jump_dark_left_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and in_light(game, (x-1)*8+y-1) 
		   and in_boundary(x-2, y-2)  
		   and !in_checkers(game, (x-2)*8+y-2)do
			add_into_moves(game, (x-2)*8+y-2)
		end
	end

	# add jump if clicked checker can jump towards right top direction
	def add_jump_dark_right_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and in_light(game, (x+1)*8+y-1) 
		   and in_boundary(x+2, y-2)  
		   and !in_checkers(game, (x+2)*8+y-2)do
			add_into_moves(game, (x+2)*8+y-2)
		end
	end

        # add jump if clicked checker can jump towards left bottom direction
	def add_jump_dark_left_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and in_light(game, (x-1)*8+y+1) 
		   and in_boundary(x-2, y+2)  
		   and !in_checkers(game, (x-2)*8+y+2)do
			add_into_moves(game, (x-2)*8+y+2)
		end
	end

	# add jump if clicked checker can jump towards right bottom direction
	def add_jump_dark_right_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and in_light(game, (x+1)*8+y+1) 
		   and in_boundary(x+2, y+2)  
		   and !in_checkers(game, (x+2)*8+y+2)do
			add_into_moves(game, (x+2)*8+y+2)
		end
	end


	#################################################################################
	# add regular moves the clicked checker can make
	def add_regular_moves(game, i) do
		cond do
			in_light_s(game, i) -> add_regular_moves_light_s(game, i)
			in_dark_s(game, i) -> add_regular_moves_dark_s(game, i)
			in_light_k(game, i) -> add_regular_moves_king(game, i)
			in_dark_k(game, i) -> add_regular_moves_king(game, i)		
		end
	end

	# add regular moves when clicked checker is a light_s
	def add_regular_moves_light_s(game, i) do
		add_regular_move_left_top(game, i)
		|> add_regular_move_right_top(i)
	end

	# add regular moves when clicked checker is a dark_s
	def add_regular_moves_dark_s(game, i) do
		add_regular_move_left_bottom(game, i)
		|> add_regular_move_right_bottom(i)
	end
	
	# add regular moves when clicked checker is a king
	def add_regular_moves_king(game, i) do
		add_regular_move_left_top(game, i)
		|> add_regular_move_right_top(i)
		|> add_regular_move_left_bottom(i)
		|> add_regular_move_right_bottom(i)
	end

	# add move if clicked checker can move towards left top direction
	def add_regular_move_left_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and !in_checkers(game, (x-1)*8+y-1)do
			add_into_moves(game, (x-1)*8+y-1)
		end		
	end

	# add move if clicked checker can move towards right top direction
	def add_regular_move_right_top(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and !in_checkers(game, (x+1)*8+y-1)do
			add_into_moves(game, (x+1)*8+y-1)
		end		
	end

	# add move if clicked checker can move towards left bottom direction
	def add_regular_move_left_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and !in_checkers(game, (x-1)*8+y+1)do
			add_into_moves(game, (x-1)*8+y+1)
		end		
	end

	# add move if clicked checker can move towards right bottom direction
	def add_regular_move_right_bottom(game, i) do
		x = div(i, 8)
		y = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and !in_checkers(game, (x+1)*8+y+1)do
			add_into_moves(game, (x+1)*8+y+1)
		end		
	end




	##############################################################################
	# handle click on a move
	def click_move(game, i) do
	end

end
