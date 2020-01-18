defmodule ExpertAdviceWeb.Controllers.ControllerHelpers do
  def render_404(conn) do
    conn
    |> Phoenix.Controller.put_view(ExpertAdviceWeb.ErrorView)
    |> Plug.Conn.put_status(:not_found)
    |> Phoenix.Controller.render("404.html", layout: nil)
  end
end
