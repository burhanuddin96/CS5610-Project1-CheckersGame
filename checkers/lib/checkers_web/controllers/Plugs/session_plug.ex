defmodule CheckersWeb.Auth do
	import Plug.Conn
	import Phoenix.Controller
	alias CheckersWeb.Router.Helpers, as: Routes

	def init(options) do
		options
	end

	def call(conn, _options) do
		user = get_session(conn, :username)
		role = get_session(conn, :role)
		if user do
			conn
			|>assign(:current_user, user)
		else
			conn
			|>assign(:current_user, nil)
		end
	end

	def auth_player(conn, _options) do
		if conn.assigns.current_user do
			conn
		else
			conn
			|> put_flash(:error, "You must be logged in to continue")
			|> redirect(to: Routes.page_path(conn, :index))
			|> halt()
		end
	end
end