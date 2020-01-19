defmodule ExpertAdviceWeb.Questions.AnswerController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Questions

  plug ExpertAdviceWeb.Plugs.SignedinAction when action in [:create, :delete]

  def create(conn, %{"answer" => %{"question_id" => qid} = answer_params}) do
    question = Questions.get_question!(qid)

    case Questions.create_answer(answer_params, conn.assigns[:current_user], question) do
      {:ok, answer} ->
        question = Questions.get_question!(answer.question_id)

        conn
        |> put_flash(:info, "Answer created successfully.")
        |> redirect(to: Routes.question_path(conn, :show, question))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(ExpertAdviceWeb.Questions.QuestionView)
        |> render(
          "show.html",
          question: question,
          answer_changeset: changeset,
          answers: Questions.list_answers_for_question(question.id)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    answer = Questions.get_answer!(id) |> ExpertAdvice.Repo.preload(:question)

    case Questions.delete_answer(answer, conn.assigns[:current_user]) do
      {:ok, _answer} ->
        conn
        |> put_flash(:info, "Answer deleted successfully.")
        |> redirect(to: Routes.question_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: :delete_answer_changeset)

        conn
        |> put_flash(:error, "Server error occured while deleting your question.")
        |> redirect(to: Routes.question_path(conn, :show, answer.question))

      {:error, :not_authorized} ->
        conn
        |> put_flash(:error, "Not authorized to delete this answer.")
        |> redirect(to: Routes.question_path(conn, :show, answer.question))
    end
  end
end
