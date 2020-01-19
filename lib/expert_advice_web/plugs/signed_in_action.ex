defmodule ExpertAdviceWeb.Plugs.SignedinAction do
  alias ExpertAdviceWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Please login")
        |> Phoenix.Controller.redirect(to: Routes.session_path(conn, :new))
        |> Plug.Conn.halt()

      _ ->
        conn
    end
  end
end
