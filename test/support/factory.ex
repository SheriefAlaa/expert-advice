defmodule ExpertAdvice.Factory do
  use ExMachina.Ecto, repo: ExpertAdvice.Repo

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  def user_factory do
    %ExpertAdvice.Accounts.User{
      firstname: "John",
      lastname: "Doe",
      email: sequence(:email, &"john.doe.#{&1}@example.com"),
      email_verified: true
    }
  end

  def credential_factory do
    %ExpertAdvice.Accounts.Credential{
      password_hash: hashpwsalt("password"),
      user: build(:user)
    }
  end
end
