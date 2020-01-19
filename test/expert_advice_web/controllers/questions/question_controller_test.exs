defmodule ExpertAdviceWeb.Questions.QuestionControllerTest do
  use ExpertAdviceWeb.ConnCase

  alias ExpertAdvice.Questions

  @create_attrs %{desc: "some desc", title: "some title"}
  @update_attrs %{desc: "some updated desc", title: "some updated title"}
  @invalid_attrs %{desc: nil, title: nil}

  setup %{conn: conn} do
    attrs = %{
      firstname: "sherief",
      lastname: "alaa ",
      email: "sheriefalaa.w@gmail.com",
      email_verified: true,
      credential: %{
        password: "strong password",
        password_confirmation: "strong password"
      }
    }

    {:ok, user} = ExpertAdvice.Accounts.create_user(attrs)

    conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})

    {:ok, question} = Questions.create_question(@create_attrs, user)

    {:ok, conn: conn, current_user: user, question: question}
  end

  describe "index" do
    test "lists all questions", %{conn: conn} do
      conn = get(conn, Routes.question_path(conn, :index))
      assert html_response(conn, 200) =~ "Get answers to difficult questions"
    end
  end

  describe "new question" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.question_path(conn, :new))
      assert html_response(conn, 200) =~ "New Question"
    end
  end

  describe "create question" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.question_path(conn, :create), question: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.question_path(conn, :show, slug)

      conn = get(conn, Routes.question_path(conn, :show, slug))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.question_path(conn, :create), question: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Question"
    end
  end

  describe "edit question" do
    test "renders form for editing chosen question", %{conn: conn, question: question} do
      conn = get(conn, Routes.question_path(conn, :edit, question))
      assert html_response(conn, 200) =~ "Edit Question"
    end
  end

  describe "update question" do
    test "redirects when data is valid", %{conn: conn, question: question} do
      conn = put(conn, Routes.question_path(conn, :update, question), question: @update_attrs)
      assert redirected_to(conn) == Routes.question_path(conn, :show, question)

      conn = get(conn, Routes.question_path(conn, :show, question))
      assert html_response(conn, 200) =~ "some updated desc"
    end

    test "renders errors when data is invalid", %{conn: conn, question: question} do
      conn = put(conn, Routes.question_path(conn, :update, question), question: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Question"
    end
  end

  describe "delete question" do
    test "deletes chosen question", %{conn: conn, question: question} do
      conn = delete(conn, Routes.question_path(conn, :delete, question))
      assert redirected_to(conn) == Routes.question_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.question_path(conn, :show, question))
      end
    end
  end
end
