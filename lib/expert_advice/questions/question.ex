defmodule ExpertAdvice.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpertAdvice.Accounts.User

  @derive {Phoenix.Param, key: :slug}
  schema "questions" do
    field :slug, :string
    field :desc, :string
    field :title, :string
    field :views, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
    has_many(:answers, ExpertAdvice.Questions.Answer)
  end

  @doc false
  def changeset(question, attrs, %User{} = user) do
    question
    |> cast(attrs, [:title, :desc])
    |> put_change(:user_id, user.id)
    |> generate_slug()
    |> validate_required([:slug, :title, :desc, :user_id])
  end

  defp generate_slug(%Ecto.Changeset{} = changeset) do
    title = get_field(changeset, :title)
    slug = get_field(changeset, :slug)

    cond do
      not is_nil(title) and not is_nil(slug) -> changeset
      is_nil(title) -> changeset
      is_nil(slug) -> change(changeset, slug: "#{Slug.slugify(title)}-#{gen_unique_string()}")
    end
  end

  def increment_views_changeset(question) do
    question
    |> cast(%{}, [])
    |> put_change(:views, question.views + 1)
  end

  defp gen_unique_string(length \\ 4),
    do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
end
