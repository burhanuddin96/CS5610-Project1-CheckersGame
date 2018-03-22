defmodule Checkers.Game do
	
	def new() do
		%{
      		p1: nil,
      		p2: nil,
      		light_s: [41,43,45,47,48,50,52,54,57,59,61,63],
      		light_k: [],
     		dark_s: [0,2,4,6,9,11,13,15,16,18,20,22],
      		dark_k: [],
      		moves: [],
      		current_player: "dark",
      		checker_selected: -1,
      		jump: false,
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

#***************************************************************************

	def client_checker_or_move(game,i) do
		##Code goes here
	end
end