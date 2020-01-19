defmodule ExpertAdviceWeb.User.SignupController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Accounts
  # alias ExpertAdviceWeb.Emails

  def new(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        render(conn, "new.html", changeset: Accounts.change_user(%Accounts.User{}))

      _ ->
        conn
        |> put_flash(:info, "You already have an account and signed in!")
        |> redirect(to: Routes.question_path(conn, :index))
    end
  end

  def create(conn, %{"user" => params}) do
    case Accounts.create_user(params) do
      {:ok, _user} ->
        # Emails.send_email_verification_mail(user)

        conn
        |> put_flash(:info, "We have created your account successfully. Please login!")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
