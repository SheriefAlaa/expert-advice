defmodule ExpertAdvice.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :title, :string
      add :desc, :text
      add :tags, :string
      add :views, :integer, default: 0
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end
  end
end
