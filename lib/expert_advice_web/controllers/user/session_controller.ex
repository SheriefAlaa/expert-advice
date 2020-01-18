defmodule ExpertAdviceWeb.User.SessionController do
  use ExpertAdviceWeb, :controller

  require Logger

  alias ExpertAdvice.Accounts

  def new(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        render(conn, "new.html", changeset: Accounts.change_user(%Accounts.User{}))

      _ ->
        conn
        |> put_flash(:info, "You already have an account and signed in!")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case Accounts.email_password_auth(email, pass) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:current_user_id, user.id)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Account does not exist, or you have used wrong email/password.")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> delete_req_header("user_token")
    |> delete_resp_header("user_token")
    |> delete_resp_cookie("user_token")
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def verify_email(conn, %{"token" => email_activation_token}) do
    user = Accounts.get_user_by_token(email_activation_token)

    case user do
      nil ->
        conn
        |> put_flash(
          :error,
          "Invalid email activation link. Please check your link in your email again."
        )
        |> redirect(to: "/")

      user ->
        case Accounts.verify_user_email(user) do
          {:ok, updated_user} ->
            conn =
              if is_nil(conn.assigns[:current_user]) do
                put_session(conn, :current_user_id, updated_user.id)
              else
                conn
              end

            conn
            |> put_flash(:info, "Thank you for verifying your email!")
            |> redirect(to: "/")

          {:error, reason} ->
            Logger.warn("User found, but could not verify email. Reason: #{inspect(reason)}")

            conn
            |> put_flash(:error, "Could not activate your email. Please contact us.")
            |> redirect(to: "/")
        end
    end
  end

  def verify_email(conn, _), do: render_404(conn)
end
