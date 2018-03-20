defmodule CheckersWeb.GamesChannel do
  use CheckersWeb, :channel

  alias Checkers.Game

  def join("games:"<>game, %{"user" => current_user}, socket) do
    if authorized?(current_user) do
      {gameState, role} = game_state(game, current_user)
      socket = socket
      |> assign(:name, game)
      |> assign(:game, gameState)
      {:ok, %{"join" => game, "game" => gameState, "role" => role}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def game_state(gname, username) do
    game = Checkers.GameBackup.load(gname) 

    if game do
      if game.p2 do
        {game, "observer"}
      else
        updated_game = Game.game_after_player2_joins(game, username)
        Checkers.GameBackup.save(gname, updated_game)
        {updated_game, "player2"}
      end
    else
      new_game = Game.game_after_player1_joins(username)
      Checkers.GameBackup.save(gname, new_game)
      {new_game, "player1"}
    end
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
