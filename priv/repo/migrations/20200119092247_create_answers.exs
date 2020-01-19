defmodule ExpertAdvice.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :body, :text
      add :user_id, references(:users, on_delete: :delete_all)
      add :question_id, references(:questions, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:answers, [:user_id])
    create unique_index(:answers, [:question_id, :user_id], name: :one_answer_from_user_index)
  end
end
