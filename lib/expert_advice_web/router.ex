defmodule ExpertAdviceWeb.Router do
  use ExpertAdviceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExpertAdviceWeb do
    pipe_through :browser

    get "/", PageController, :index

    # Login
    get "/account/login", User.SessionController, :new
    post "/account/login", User.SessionController, :create

    # Sign up
    get "/account/signup", User.SignupController, :new
    resources("/account/", User.SignupController, only: [:create])

    # Account specific actions
    get "/account/logout", User.SessionController, :delete

    # Email verify
    get "/account/verify_email/:token", User.SessionController, :verify_email

    scope "/user/password_reset" do
      resources("/", User.PasswordController, only: [:new, :create])

      get("/:reset_token/edit", User.PasswordController, :edit)
      put("/:reset_token", User.PasswordController, :update)
    end
  end
end
