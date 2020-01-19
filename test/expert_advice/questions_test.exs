defmodule ExpertAdvice.QuestionsTest do
  use ExpertAdvice.DataCase

  import ExpertAdvice.Factory

  alias ExpertAdvice.Questions

  describe "questions" do
    alias ExpertAdvice.Questions.Question

    @valid_attrs %{desc: "some desc", title: "some title"}
    @update_attrs %{desc: "some updated desc", title: "some updated title"}
    @invalid_attrs %{desc: nil, title: nil}

    def question_fixture(attrs \\ %{}) do
      credential = insert(:credential)

      {:ok, question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Questions.create_question(credential.user)

      question
    end

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Questions.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Questions.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      assert {:ok, %Question{} = question} = Questions.create_question(@valid_attrs, insert(:credential).user)
      assert question.desc == "some desc"
      assert question.title == "some title"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs, insert(:credential).user)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      user = ExpertAdvice.Accounts.get_user!(question.user_id)
      assert {:ok, %Question{} = question} = Questions.update_question(question, @update_attrs, user)
      assert question.desc == "some updated desc"
      assert question.title == "some updated title"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      user = ExpertAdvice.Accounts.get_user!(question.user_id)
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs, user)
      assert question == Questions.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      question = ExpertAdvice.Repo.preload(question, :user)
      assert {:ok, %Question{}} = Questions.delete_question(question, question.user)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end

  describe "answers" do
    alias ExpertAdvice.Questions.Answer

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    test "list_answers/0 returns all answers" do
      _answer = insert(:answer)
      assert length(Questions.list_answers()) == 1
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = insert(:answer)
      assert Questions.get_answer!(answer.id).id == answer.id
    end

    test "create_answer/1 with valid data creates a answer" do
      question = insert(:question)
      assert {:ok, %Answer{} = answer} = Questions.create_answer(@valid_attrs, question.user, question)
      assert answer.body == "some body"
    end

    test "create_answer/1 with invalid data returns error changeset" do
      question = insert(:question)
      assert {:error, %Ecto.Changeset{}} = Questions.create_answer(@invalid_attrs, question.user, question)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = insert(:answer)
      assert {:ok, %Answer{} = answer} = Questions.update_answer(answer, @update_attrs, answer.user, answer.question)
      assert answer.body == "some updated body"
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = insert(:answer)
      assert {:error, %Ecto.Changeset{}} = Questions.update_answer(answer, @invalid_attrs, answer.user, answer.question)
      assert answer.id == Questions.get_answer!(answer.id).id
    end

    test "delete_answer/1 deletes the answer" do
      answer = insert(:answer)
      assert {:ok, %Answer{}} = Questions.delete_answer(answer, answer.user)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = insert(:answer)
      assert %Ecto.Changeset{} = Questions.change_answer(answer)
    end
  end
end
