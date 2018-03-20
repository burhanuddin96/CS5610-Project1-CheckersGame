defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller

  def index(conn, _params) do
  	if !conn.assigns.current_user do
  		render conn, "index.html"
  	else
  		redirect(conn, to: page_path(conn, :gname))
  	end
  end

  def gname(conn, _params) do
    render conn, "gname.html"
  end

  def create(conn, %{"name" => game} = _params) do
  	case String.trim(game) do
  		"" -> conn
  			  |> put_flash(:error, "Name cannot be blank!")
  			  |> redirect(to: page_path(conn, :gname))
  		_ -> redirect(conn, to: "/game/"<>game)
  	end
  end

  def game(conn, params) do
    render conn, "game.html", game: params["game"]
  end
end
