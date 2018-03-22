defmodule CheckersWeb.GamesChannel do
  use CheckersWeb, :channel

  alias Checkers.Game

  def join("games:"<>game, %{"user" => current_user}, socket) do
    if authorized?(current_user) do
      gameInstance = Checkers.GameBackup.load(game) || Game.new()
      {gameState, role} = Game.clientview_after_user_joins(gameInstance, current_user)
      IO.inspect gameState
      Checkers.GameBackup.save(game, gameState)
      socket = socket
      |> assign(:name, game)
      |> assign(:role, role)
      send self(), {:after_join, gameState}
      :ok = Checkers.ChannelMonitor.monitor(:games, self(), {__MODULE__, :leave, [socket, game, role]})
      {:ok, %{"join" => game, "game" => gameState, "role" => role}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("click", %{"tileID" => tileID}, socket) do
    game = Game.click_checker_or_move(Checkers.GameBackup.load(socket.assigns.name), tileID)
    Checkers.GameBackup.save(socket.assigns[:name], game)
    broadcast_from socket, "shout", game
    {:reply, {:ok, %{"game" => game}}, socket}
  end
  
  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast_from socket, "shout", payload
    {:noreply, socket}
  end

  def handle_info({:after_join, game}, socket) do
    broadcast_from socket, "shout", game
    {:noreply, socket}
  end

  def handle_info(:after_leave, socket) do
    broadcast_from socket, "shout", socket.assigns[:game]
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def terminate(_msg, socket) do
    game = Game.clientview_after_player_leaves(Checkers.GameBackup.load(socket.assigns.name), socket.assigns.role)
    Checkers.GameBackup.save(socket.assigns.name, game)
    broadcast! socket, "shout", game
    :ok = Checkers.ChannelMonitor.demonitor(:games, self())
end

  def leave(socket, name, role) do
    game = Game.clientview_after_player_leaves(Checkers.GameBackup.load(socket.assigns.name), role)
    Checkers.GameBackup.save(name, game)
    socket = assign(socket, :game, game)
    send(self, :after_leave)
    {:ok,socket}
  end
end
