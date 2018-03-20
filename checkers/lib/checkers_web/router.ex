defmodule CheckersWeb.Router do
  use CheckersWeb, :router
  import CheckersWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CheckersWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CheckersWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    
    post "/session", SessionController, :create
    delete "/session", SessionController, :delete
  end

  scope "/", CheckersWeb do
    pipe_through [:browser, :auth_player]

    get "/gamename", PageController, :gname
    post "/gamename", PageController, :create
    get "/game/:game", PageController, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", CheckersWeb do
  #   pipe_through :api
  # end
end
