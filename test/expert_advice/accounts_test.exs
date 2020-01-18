defmodule ExpertAdvice.AccountsTest do
  use ExpertAdvice.DataCase

  import ExpertAdvice.Factory

  alias ExpertAdvice.Accounts
  alias ExpertAdvice.Accounts.Credential

  describe "users" do
    alias ExpertAdvice.Accounts.User

    @password "strong password"

    @valid_attrs %{
      email: "email@example.com",
      firstname: "some firstname",
      lastname: "some lastname",
      credential: %{
        password: @password,
        password_confirmation: @password
      }
    }
    @update_attrs %{
      email: "sheriefalaa@outlook.com",
      firstname: "some updated firstname",
      lastname: "some updated lastname"
    }
    @invalid_attrs %{email: nil, firstname: nil, lastname: nil}

    def user_fixture() do
      user =
        insert(:user, %{
          email: "email@example.com",
          firstname: "some firstname",
          lastname: "some lastname"
        })

      credential_attrs = %{
        password: @password,
        password_confirmation: @password
      }

      {:ok, credential} =
        Credential.changeset(%Credential{user_id: user.id}, credential_attrs)
        |> Repo.insert()

      c = credential |> Repo.preload(:user)
      c.user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "email@example.com"
      assert user.firstname == "some firstname"
      assert user.lastname == "some lastname"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      user = ExpertAdvice.Repo.preload(user, :credential)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "sheriefalaa@outlook.com"
      assert user.firstname == "some updated firstname"
      assert user.lastname == "some updated lastname"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end
  end

  describe "credentials" do
    @password "strong password"

    def credential_fixture() do
      user = insert(:user)

      credential_attrs = %{
        password: @password,
        password_confirmation: @password
      }

      {:ok, credential} =
        Credential.changeset(%Credential{user_id: user.id}, credential_attrs)
        |> Repo.insert()

      credential |> Repo.preload(:user)
    end

    test "when correct credentials are given, {:ok, user} is returned" do
      credential = credential_fixture()
      {:ok, user} = Accounts.email_password_auth(credential.user.email, @password)

      assert user.id == credential.user.id
    end

    test "when invalid credentials are provided, {:error, reason} is returned" do
      credential = credential_fixture()

      assert {:error, :invalid_password} =
               Accounts.email_password_auth(credential.user.email, "bad password")
    end
  end
end
