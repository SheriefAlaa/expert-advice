defmodule ExpertAdvice.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpertAdvice.Accounts.User

  schema "questions" do
    field :desc, :string
    field :tags, :string
    field :title, :string
    field :views, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
  end

  @doc false
  def changeset(question, attrs, %User{} = user) do
    question
    |> cast(attrs, [:title, :desc, :tags])
    |> put_change(:user_id, user.id)
    |> validate_required([:title, :desc, :user_id])
  end

  def increment_views(question) do
    question
    |> cast(%{}, [])
    |> put_change(:views, question.views + 1)
  end
end
