defmodule ExpertAdvice.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string
      add :lastname, :string
      add :email, :string
      add :email_activation_token, :string, default: false
      add :email_verified, :boolean, default: false

      timestamps(type: :timestamptz)
    end

    create(unique_index("users", [:email]))
  end
end
