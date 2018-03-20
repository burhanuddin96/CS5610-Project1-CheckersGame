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
	def in_moves(game, i)
		Enum.any?(game.moves, fn(x) -> x == i end)
	end

	# check whether clicked position is in checkers
	def in_checkers(game, i)
		Enum.any?(game.light_s, fn(x) -> x == i end) or
		Enum.any?(game.light_k, fn(x) -> x == i end) or
		Enum.any?(game.dark_s, fn(x) -> x == i end) or
		Enum.any?(game.dark_k, fn(x) -> x == i end)
	end

	# handle click on a checker
     	def click_checker(game, i)
		game = add_jumps(game, i)
		if length(game.moves) == 0 do
			add_moves(game, i)
		else
  			game
		end
	end

	# add jumps this checker can make
	def add_jmps(game, i)
	end

	# add moves this checker can make
	def add_moves(game, i)
	end

end
