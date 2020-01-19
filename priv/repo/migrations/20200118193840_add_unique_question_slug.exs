defmodule ExpertAdvice.Repo.Migrations.AddUniqueQuestionSlug do
  use Ecto.Migration

  def change do
    create(unique_index("questions", [:slug]))
  end
end
