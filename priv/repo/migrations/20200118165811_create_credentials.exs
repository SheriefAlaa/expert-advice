defmodule ExpertAdvice.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :reset_token, :string
      add :reset_token_created, :utc_datetime
      add :password_hash, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:credentials, [:user_id])
  end
end
