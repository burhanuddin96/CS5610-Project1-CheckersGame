defmodule Checkers.Game do
	
	def new() do
		%{
      		p1: nil,
      		p2: nil,
      		light_s: [29,43,45,47,48,50,52,54,57,59,61,63],
      		light_k: [],
     		dark_s: [0,2,4,6,9,11,13,15,16,18,20,22],
      		dark_k: [],
      		moves: [],
      		current_player: "dark",
      		checker_selected: -1,
      		jump: false,
		winner: nil
		}
	end


	def clientview_after_user_joins(game, user) do
		if (!game.p1) do
			IO.inspect "Player 1 joining..."
			game = Map.replace!(game, :p1, user)
			{game,"dark"}
		else
			if (!game.p2) do
				IO.inspect "Player 2 joining..."
				game = Map.replace!(game, :p2, user)
				{game,"light"}	
			else
				IO.inspect "Observer joining..."
				{game,"observer"}
			end
		end
	end


	def clientview_after_player_leaves(game, role) do
		case role do
			"dark" ->
				IO.inspect "Dark Leaving"
				game
				|> Map.replace!(:p1, nil)
			"light" ->
				IO.inspect "Light Leaving"
				game
				|> Map.replace!(:p2, nil)
			"observer" ->
				IO.inspect "Observer Leaving"
				game
		end
	end


	#############################################################################
	# handle click event on board
	# can click on a checker or a movement
        def click_checker_or_move(game, i) do
   		IO.inspect "click_checker_or_move"
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
	IO.inspect "in_checkers"
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
	IO.inspect "click_checker_or_move"
		game = clear_moves(game)  # clear previous moves
		       |> Map.put(:jump, false) # jump change to false
		       |> add_jumps(i)
		game = if length(game.moves) == 0 do # can make regular moves only 
			 add_regular_moves(game, i)  # when there is no jump
			#else add_regular_moves(game, i)
		       else game
		       end
		Map.put(game, :checker_selected, i) # set selected checker
	end

	# clear moves in the given game
	def clear_moves(game) do
	IO.inspect "clear_moves"
		Map.put(game, :moves, [])
	end

	# add jumps this checker can make
	def add_jumps(game, i) do
		cond do
			in_light_s(game, i) -> add_jump_light_s(game, i)
			in_light_k(game, i) -> add_jump_light_k(game, i)
			in_dark_s(game, i) -> add_jump_dark_s(game, i)
			in_dark_k(game, i) -> add_jump_dark_k(game, i)
			true -> game
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
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and in_dark(game, (x-1)+8*(y-1)) 
		   and in_boundary(x-2, y-2)  
		   and !in_checkers(game, (x-2)+8*(y-2)) do
			add_into_moves(game, (x-2)+8*(y-2))
			|> Map.put(:jump, true)
		else game
		end
	end

	# add jump if clicked checker can jump towards right top direction
	def add_jump_light_right_top(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and in_dark(game, (x+1)+8*(y-1)) 
		   and in_boundary(x+2, y-2)  
		   and !in_checkers(game, (x+2)+8*(y-2)) do
			add_into_moves(game, (x+2)+8*(y-2))
			|> Map.put(:jump, true)
		else game
		end
	end

        # add jump if clicked checker can jump towards left bottom direction
	def add_jump_light_left_bottom(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and in_dark(game, (x-1)+8*(y+1)) 
		   and in_boundary(x-2, y+2)  
		   and !in_checkers(game, (x-2)+8*(y+2)) do
			add_into_moves(game, (x-2)+8*(y+2))
			|> Map.put(:jump, true)
		else game
		end
	end

	# add jump if clicked checker can jump towards right bottom direction
	def add_jump_light_right_bottom(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and in_dark(game, (x+1)+8*(y+1)) 
		   and in_boundary(x+2, y+2)  
		   and !in_checkers(game, (x+2)+8*(y+2)) do
			add_into_moves(game, (x+2)+8*(y+2))
			|> Map.put(:jump, true)
		else game
		end
	end

	# check whether game position is in board's boundary
	def in_boundary(x,y) do
	IO.inspect "in_boundary"
		x >= 0 and x <= 7 and y >= 0 and y <= 7
	end

	# add given position into moves of given game
	def add_into_moves(game, i) do
	IO.inspect "add_into_moves"
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
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and in_light(game, (x-1)+8*(y-1)) 
		   and in_boundary(x-2, y-2)  
		   and !in_checkers(game, (x-2)+8*(y-2)) do
			add_into_moves(game, (x-2)+8*(y-2))
			|> Map.put(:jump, true)
		else game
		end
	end

	# add jump if clicked checker can jump towards right top direction
	def add_jump_dark_right_top(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and in_light(game, (x+1)+8*(y-1)) 
		   and in_boundary(x+2, y-2)  
		   and !in_checkers(game, (x+2)+8*(y-2)) do
			add_into_moves(game, (x+2)+8*(y-2))
			|> Map.put(:jump, true)
		else game
		end
	end

        # add jump if clicked checker can jump towards left bottom direction
	def add_jump_dark_left_bottom(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and in_light(game, (x-1)+8*(y+1)) 
		   and in_boundary(x-2, y+2)  
		   and !in_checkers(game, (x-2)+8*(y+2)) do
			add_into_moves(game, (x-2)+8*(y+2))
			|> Map.put(:jump, true)
		else game
		end
	end

	# add jump if clicked checker can jump towards right bottom direction
	def add_jump_dark_right_bottom(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and in_light(game, (x+1)+8*(y+1)) 
		   and in_boundary(x+2, y+2)  
		   and !in_checkers(game, (x+2)+8*(y+2)) do
			add_into_moves(game, (x+2)+8*(y+2))
			|> Map.put(:jump, true)
		else game
		end
	end


	#################################################################################
	# add regular moves the clicked checker can make
	def add_regular_moves(game, i) do
	IO.inspect "add_regular_moves"
		cond do
			in_light_s(game, i) -> add_regular_moves_light_s(game, i)
			in_dark_s(game, i) -> add_regular_moves_dark_s(game, i)
			in_light_k(game, i) -> add_regular_moves_king(game, i)
			in_dark_k(game, i) -> add_regular_moves_king(game, i)	
			true -> game	
		end
	end

	# add regular moves when clicked checker is a light_s
	def add_regular_moves_light_s(game, i) do
		add_regular_move_left_top(game, i)
		|> add_regular_move_right_top(i)
	end

	# add regular moves when clicked checker is a dark_s
	def add_regular_moves_dark_s(game, i) do
	IO.inspect "add_regular_moves_dark_s"
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
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y-1)
		   and !in_checkers(game, (x-1)+8*(y-1)) do
			add_into_moves(game, (x-1)+8*(y-1))
		else game
		end		
	end

	# add move if clicked checker can move towards right top direction
	def add_regular_move_right_top(game, i) do
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y-1)
		   and !in_checkers(game, (x+1)+8*(y-1)) do
			add_into_moves(game, (x+1)+8*(y-1))
		else game
		end		
	end

	# add move if clicked checker can move towards left bottom direction
	def add_regular_move_left_bottom(game, i) do
	IO.inspect "add_regular_move_left_bottom"
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x-1, y+1)
		   and !in_checkers(game, (x-1)+8*(y+1)) do
			add_into_moves(game, (x-1)+8*(y+1))
		else game
		end		
	end

	# add move if clicked checker can move towards right bottom direction
	def add_regular_move_right_bottom(game, i) do
	IO.inspect "add_regular_move_right_bottom"
		y = div(i, 8)
		x = rem(i, 8)
		if in_boundary(x+1, y+1)
		   and !in_checkers(game, (x+1)+8*(y+1)) do
			add_into_moves(game, (x+1)+8*(y+1))
		else game
		end		
	end


	##############################################################################
	# handle click on a move
	def click_move(game, i) do
	IO.inspect "click move"
		if game.jump do
			click_jump(game, i)
		else
			click_regular_move(game, i)
			|> switch_player()
			|> clear_moves()
			|> check_winner()
		end
	end

	# switch current player
	def switch_player(game) do
	IO.inspect "switch_player"
		if game.current_player == "dark" do
			Map.put(game, :current_player, "light")
		else
			Map.put(game, :current_player, "dark")
		end
	end

	# click a regular move
	def click_regular_move(game, i) do
        IO.inspect "click regular move"
		cond do
			in_light_s(game, game.checker_selected) -> move_light_s(game, i)
			in_light_k(game, game.checker_selected) -> move_light_k(game, i)
			in_dark_s(game, game.checker_selected) -> move_dark_s(game, i)
			in_dark_k(game, game.checker_selected) -> move_dark_k(game, i)
			true -> game
		end
	end


	#####################################################################
	#regular move on light checker
	# move a light_s
	def move_light_s(game, i) do
		if become_light_king(i) do
			remove_from_light_s(game, game.checker_selected)
			|> add_into_light_k(i)
		else
			remove_from_light_s(game, game.checker_selected)
			|> add_into_light_s(i)
		end
	end	

	# move a light_k
	def move_light_k(game, i) do
		remove_from_light_k(game, game.checker_selected)
		|> add_into_light_k(i)
	end

	# checker whether will become a light king
	def become_light_king(i) do
		div(i, 8) == 0
	end

	# remove chekcer from light_s
	def remove_from_light_s(game, i) do
		light_s = Enum.filter(game.light_s, fn(x) -> x != i end)
		Map.put(game, :light_s, light_s)
	end

	# add chekcer checker into light_s
	def add_into_light_s(game, i) do
		light_s = game.light_s ++ [i]
		Map.put(game, :light_s, light_s)
	end

	# remove chekcer from light_k
	def remove_from_light_k(game, i) do
		light_k = Enum.filter(game.light_k, fn(x) -> x != i end)
		Map.put(game, :light_k, light_k)
	end

	# add chekcer checker into light_k
	def add_into_light_k(game, i) do
		light_k = game.light_k ++ [i]
		Map.put(game, :light_k, light_k)
	end
        
	#####################################################################
	#regular move on dark checker
        # move a dark_s
	def move_dark_s(game, i) do
		if become_dark_king(i) do
			remove_from_dark_s(game, game.checker_selected)
			|> add_into_dark_k(i)
		else
			remove_from_dark_s(game, game.checker_selected)
			|> add_into_dark_s(i)
		end
	end	

	# move a dark_k
	def move_dark_k(game, i) do
		remove_from_dark_k(game, game.checker_selected)
		|> add_into_dark_k(i)
	end

	# checker whether will become a dark king
	def become_dark_king(i) do
		div(i, 8) == 7
	end

	# remove chekcer from dark_s
	def remove_from_dark_s(game, i) do
		dark_s = Enum.filter(game.dark_s, fn(x) -> x != i end)
		Map.put(game, :dark_s, dark_s)
	end

	# add chekcer checker into dark_s
	def add_into_dark_s(game, i) do
		dark_s = game.dark_s ++ [i]
		Map.put(game, :dark_s, dark_s)
	end

	# remove chekcer from dark_k
	def remove_from_dark_k(game, i) do
		dark_k = Enum.filter(game.dark_k, fn(x) -> x != i end)
		Map.put(game, :dark_k, dark_k)
	end

	# add chekcer checker into dark_k
	def add_into_dark_k(game, i) do
		dark_k = game.dark_k ++ [i]
		Map.put(game, :dark_k, dark_k)
	end


	##############################################################################
	# click a jump
	def click_jump(game, i) do
        IO.inspect "click jump"
		cond do
			in_light_s(game, game.checker_selected) -> jump_light_s(game, i)
			in_light_k(game, game.checker_selected) -> jump_light_k(game, i)
			in_dark_s(game, game.checker_selected) -> jump_dark_s(game, i)
			in_dark_k(game, game.checker_selected) -> jump_dark_k(game, i)
			true -> game
		end
	end

	#####################################################################
	# jump on light checker
	# jump a light_s
	def jump_light_s(game, i) do
	 y1 = div(i, 8)
   	 x1 = rem(i, 8)
	 y2 = div(game.checker_selected, 8)
   	 x2 = rem(game.checker_selected, 8)
	 y3 = div(y1 + y2, 2)
   	 x3 = div(x1 + x2, 2)
	 game = if become_light_king(i) do
			remove_from_light_s(game, game.checker_selected)
			|> add_into_light_k(i)
			|> remove_from_dark(y3 * 8 + x3)
		else
			remove_from_light_s(game, game.checker_selected)
			|> add_into_light_s(i)
			|> remove_from_dark(y3 * 8 + x3)
		end
	 game = clear_moves(game) # check continues jump
		|> add_jumps(i)
	 if length(game.moves) > 0 do
		click_checker_or_move(game, i)
	 else
         	switch_player(game) 
		|> check_winner()
	 end
	end	

	def jump_light_k(game, i) do
	 y1 = div(i, 8)
   	 x1 = rem(i, 8)
	 y2 = div(game.checker_selected, 8)
   	 x2 = rem(game.checker_selected, 8)
	 y3 = div(y1 + y2, 2)
   	 x3 = div(x1 + x2, 2)
	 game = remove_from_light_k(game, game.checker_selected)
		|> add_into_light_k(i)
		|> remove_from_dark(y3 * 8 + x3)
	 game = clear_moves(game) # check continues jump
		|> add_jumps(i)
	 if length(game.moves) > 0 do
		click_checker_or_move(game, i)
	 else
         	switch_player(game) 
		|> check_winner()
	 end
	end	
	
	# remove checker from dark
	def remove_from_dark(game, i) do
		if in_dark_s(game, i) do
			remove_from_dark_s(game, i)
		else
			remove_from_dark_k(game, i)
		end
	end

	#####################################################################
	# jump on dark checker
	# jump a dark_s
	def jump_dark_s(game, i) do
	 y1 = div(i, 8)
   	 x1 = rem(i, 8)
	 y2 = div(game.checker_selected, 8)
   	 x2 = rem(game.checker_selected, 8)
	 y3 = div(y1 + y2, 2)
   	 x3 = div(x1 + x2, 2)
	 game = if become_dark_king(i) do
			remove_from_dark_s(game, game.checker_selected)
			|> add_into_dark_k(i)
			|> remove_from_light(y3 * 8 + x3)
		else
			remove_from_dark_s(game, game.checker_selected)
			|> add_into_dark_s(i)
			|> remove_from_light(y3 * 8 + x3)
		end
	 game = clear_moves(game) # check continues jump
		|> add_jumps(i)
	 if length(game.moves) > 0 do
		click_checker_or_move(game, i)
	 else
         	switch_player(game)
		|> check_winner()
	 end
	end	

	def jump_dark_k(game, i) do
	 y1 = div(i, 8)
   	 x1 = rem(i, 8)
	 y2 = div(game.checker_selected, 8)
   	 x2 = rem(game.checker_selected, 8)
	 y3 = div(y1 + y2, 2)
   	 x3 = div(x1 + x2, 2)
	 game = remove_from_dark_k(game, game.checker_selected)
		|> add_into_dark_k(i)
		|> remove_from_light(y3 * 8 + x3)
	 game = clear_moves(game) # check continues jump
		|> add_jumps(i)
	 if length(game.moves) > 0 do
		click_checker_or_move(game, i)
	 else
         	switch_player(game)
		|> check_winner()
	 end
	end	
	
	# remove checker from light
	def remove_from_light(game, i) do
		if in_light_s(game, i) do
			remove_from_light_s(game, i)
		else
			remove_from_light_k(game, i)
		end
	end

	########################################################################
	# check winner
	def check_winner(game) do
		cond do
			length(game.light_k) == 0 and length(game.light_s) == 0
			-> Map.put(game, :winner, "dark")
			length(game.dark_k) == 0 and length(game.dark_s) == 0
			-> Map.put(game, :winner, "light")
			true -> game
		end
	end

end
