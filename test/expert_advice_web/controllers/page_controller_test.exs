defmodule ExpertAdviceWeb.PageControllerTest do
  use ExpertAdviceWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LIST QUESTIONS..."
  end
end
