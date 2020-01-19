defmodule ExpertAdviceWeb.Questions.QuestionController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Questions
  alias ExpertAdvice.Questions.Question

  plug ExpertAdviceWeb.Plugs.SignedinAction when action in [:create, :new, :update, :delete]

  def index(conn, _params) do
    questions = Questions.list_questions()
    render(conn, "index.html", questions: questions)
  end

  def new(conn, _params) do
    changeset = Questions.change_question(%Question{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"question" => question_params}) do
    case Questions.create_question(question_params, conn.assigns[:current_user]) do
      {:ok, question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: Routes.question_path(conn, :show, question))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    case Questions.get_question_by_slug!(slug) do
      nil ->
        render_404(conn)

      question ->
        Questions.increment_views(question)
        render(conn, "show.html", question: question)
    end
  end

  def edit(conn, %{"slug" => slug}) do
    question = Questions.get_question_by_slug!(slug)
    user = conn.assigns[:current_user]

    if question.user_id != user.id do
      access_denied(conn)
    else
      changeset = Questions.change_question(question)
      render(conn, "edit.html", question: question, changeset: changeset)
    end
  end

  def update(conn, %{"slug" => slug, "question" => question_params}) do
    question = Questions.get_question_by_slug!(slug)

    user = conn.assigns[:current_user]

    # TODO: move this logic to the changeset. Better make an update changeset.
    if user.id == question.user_id do
      case Questions.update_question(question, question_params, user) do
        {:ok, question} ->
          conn
          |> put_flash(:info, "Question updated successfully.")
          |> redirect(to: Routes.question_path(conn, :show, question))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", question: question, changeset: changeset)
      end
    else
      access_denied(conn)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    question = Questions.get_question_by_slug!(slug)

    case Questions.delete_question(question, conn.assigns[:current_user]) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question deleted successfully.")
        |> redirect(to: Routes.question_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: :delete_question_changeset)

        conn
        |> put_flash(:error, "Server error occured while deleting your question.")
        |> redirect(to: Routes.question_path(conn, :show, question))

      {:error, :not_authorized} ->
        access_denied(conn)
    end
  end

  defp access_denied(conn) do
    conn
    |> put_flash(:error, "Not authorized to edit/delete this question.")
    |> redirect(to: Routes.question_path(conn, :index))
  end
end
