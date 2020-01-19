defmodule ExpertAdvice.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false
  alias ExpertAdvice.Repo

  alias ExpertAdvice.Questions.Question
  alias ExpertAdvice.Accounts.User

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  def increment_views(question) do
    question
    |> Question.increment_views_changeset()
    |> Repo.update()
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  def get_question_by_slug!(slug) do
    Repo.get_by!(Question, slug: slug)
  end

  def create_question(attrs \\ %{}, %User{} = user) do
    %Question{}
    |> Question.changeset(attrs, user)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs, %User{} = user) do
    question
    |> Question.changeset(attrs, user)
    |> Repo.update()
  end

  @doc """
  Deletes a Question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question, %User{id: user_id}) do
    if user_id == question.user_id do
      Repo.delete(question)
    else
      {:error, :not_authorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{source: %Question{}}

  """
  def change_question(%Question{} = question) do
    Question.changeset(question, %{}, %User{})
  end

  alias ExpertAdvice.Questions.Answer

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer)
  end

  def list_answers_for_question(question_id) do
    from(
      a in Answer,
      where: a.question_id == ^question_id,
      preload: [:user]
    ) |> Repo.all()
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs \\ %{}, %User{} = user, %Question{} = question) do
    %Answer{}
    |> Answer.changeset(attrs, user, question)
    |> Repo.insert()
    |> IO.inspect
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs, user, %Question{} = question) do
    answer
    |> Answer.changeset(attrs, user, question)
    |> Repo.update()
  end

  @doc """
  Deletes a Answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer, %User{id: user_id}) do
    if user_id == answer.user_id do
      Repo.delete(answer)
    else
      {:error, :not_authorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{source: %Answer{}}

  """
  def change_answer(%Answer{} = answer) do
    Answer.changeset(answer, %{}, %User{}, %Question{})
  end
end
