defmodule ExpertAdvice.Repo.Migrations.AddQuestionSlugRemoveTags do
  use Ecto.Migration

  def change do
    alter(table("questions")) do
      remove :tags
      add :slug, :string, null: false
    end
  end
end
