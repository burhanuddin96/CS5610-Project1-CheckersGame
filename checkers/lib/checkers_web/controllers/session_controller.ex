defmodule CheckersWeb.SessionController do
  use CheckersWeb, :controller


  def create(conn, %{"username" => username}) do
    if !conn.assigns.current_user do
    	conn
    	|> put_session(:username, username)
      |> put_session(:role, nil)
    	|> put_flash(:info, "Logged in successfully as #{username}.")	
      |> redirect(to: page_path(conn, :gname)) 
    else
    	conn
    	|> put_flash(:error, "Cannot create a session. Try again.")
  	end
 end

  def delete(conn, _params) do
  	conn
    |> delete_session(:username)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: page_path(conn, :index)) 
  end
end