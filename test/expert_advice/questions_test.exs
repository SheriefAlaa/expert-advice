defmodule ExpertAdvice.QuestionsTest do
  use ExpertAdvice.DataCase

  import ExpertAdvice.Factory

  alias ExpertAdvice.Questions

  describe "questions" do
    alias ExpertAdvice.Questions.Question

    @valid_attrs %{desc: "some desc", tags: "some tags", title: "some title"}
    @update_attrs %{desc: "some updated desc", tags: "some updated tags", title: "some updated title"}
    @invalid_attrs %{desc: nil, tags: nil, title: nil}

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
      assert question.tags == "some tags"
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
      assert question.tags == "some updated tags"
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
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end
end
