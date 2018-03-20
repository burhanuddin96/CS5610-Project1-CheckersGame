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

end