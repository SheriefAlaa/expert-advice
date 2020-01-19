defmodule ExpertAdvice.Questions.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpertAdvice.Accounts.User
  alias ExpertAdvice.Questions.Question

  schema "answers" do
    field :body, :string

    belongs_to(:question, Question)
    belongs_to(:user, User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answer, attrs, %User{id: uid}, %Question{id: qid}) do
    answer
    |> cast(attrs, [:body])
    |> put_change(:user_id, uid)
    |> put_change(:question_id, qid)
    |> validate_required([:body, :user_id, :question_id])
    |> unique_constraint(:question_id_user_id,
      name: :one_answer_from_user_index,
      message: "You cannot answer the same question again."
    )
  end
end
