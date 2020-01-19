defmodule ExpertAdviceWeb.User.PasswordController do
  use ExpertAdviceWeb, :controller

  require Logger

  alias ExpertAdvice.Accounts
  alias ExpertAdvice.Accounts.{User, Credential}
  alias ExpertAdviceWeb.Auth.Tools
  # alias ExpertAdviceWeb.Emails

  use Timex

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, action: Routes.password_path(conn, :create))
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    credential =
      case email do
        nil ->
          nil

        email ->
          Accounts.get_user_credential(email)

      end

    case credential do
      nil ->
        conn
        |> put_flash(:error, "We have no record of your email.")
        |> redirect(to: Routes.question_path(conn, :index))

      credential ->
        case Tools.reset_password_token(credential) do
          {:ok, _updated_credential} ->

            # ExpertAdvice.Repo.preload(updated_credential, :user)
            # |> Emails.send_password_reset_email()

            conn
            |> put_flash(:info, "You will receive a password reset link in your #{email} inbox soon.")
            |> redirect(to: Routes.question_path(conn, :index))

          {:error, changeset} ->
            Logger.error("Could not create credential reset: #{inspect(changeset)}")

            conn
            |> put_flash(:error, "Something wrong happened, please try again.")
            |> redirect(to: Routes.password_path(conn, :new))
        end


    end
  end

  def edit(conn, %{"reset_token" => token}) do
    credential = Accounts.get_credential_by_token(token)

    case credential do
      nil ->
        conn
        |> put_flash(:error, "Invalid reset token")
        |> redirect(to: Routes.password_path(conn, :new))

      credential ->
        %{reset_token_created: reset_token_created} = credential

        if Tools.expired?(reset_token_created) do
          Tools.nullify_token(credential)

          conn
          |> put_flash(:error, "Password reset token expired")
          |> redirect(to: Routes.password_path(conn, :new))
        else
          changeset = Accounts.change_credential(%Credential{})

          conn
          |> render("edit.html", changeset: changeset, token: token, credential: credential)
        end
    end
  end

  def update(conn, params) do
    credential =
      params
      |> Map.get("reset_token")
      |> Accounts.get_credential_by_token()

    case credential do
      nil ->
        conn
        |> put_flash(:error, "Invalid reset token")
        |> redirect(to: Routes.password_path(conn, :new))

      credential ->
        %{reset_token_created: reset_token_created} = credential

        if Tools.expired?(reset_token_created) do
          Tools.nullify_token(credential)

          conn
          |> put_flash(:error, "Password reset token expired")
          |> redirect(to: Routes.password_path(conn, :new))
        else
          case Accounts.update_credential(credential, params["credential"]) do
            {:ok, _response} ->
              Tools.nullify_token(credential)

              conn
              |> put_flash(:info, "Password reset successfully!")
              |> redirect(to: Routes.question_path(conn, :index))

            {:error, changeset} ->

              conn
              |> render("edit.html",
                changeset: changeset,
                credential: credential,
                token: params["reset_token"]
              )
          end
        end
    end
  end
end


defmodule ExpertAdviceWeb.Auth.Tools do
  alias ExpertAdvice.Accounts
  @key_length 16

  def nullify_token(credential) do
    Accounts.update_credential_token(credential, %{
      reset_token: nil,
      reset_token_created: nil
    })
  end

  # sets the token & sent at in the database for the credential
  def reset_password_token(credential) do
    token = random_string()
    now = DateTime.utc_now()

    credential
    |> Accounts.update_credential_token(%{reset_token: token, reset_token_created: now})
  end

  def random_string() do
    @key_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @key_length)
  end

  def expired?(datetime), do: Timex.after?(Timex.now(), Timex.shift(datetime, days: 1))
end
