defmodule ExpertAdvice.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpertAdvice.Accounts.Credential
  alias ExpertAdvice.Questions.{Question, Answer}

  schema "users" do
    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :email_activation_token, :string
    # We auto verify emails until we hookup an email service like SendGrid. -Sherief
    field :email_verified, :boolean, default: true

    timestamps(type: :utc_datetime)

    has_many(:questions, Question)
    has_many(:answers, Answer)
    has_one(:credential, Credential)
  end

  @allowed [:firstname, :lastname, :email]
  @required [:firstname, :lastname, :email]

  @doc false
  def changeset(user, attrs, allowed \\ @allowed) do
    user
    |> cast(attrs, allowed)
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
    |> add_email_activation_token()
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

  def update_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> email_changed(user)
  end

  def verify_email_changeset(user) do
    user
    |> cast(%{}, [])
    |> put_change(:email_verified, true)
  end

  def add_email_activation_token(%Ecto.Changeset{} = changeset) do
    case get_field(changeset, :email_activation_token) do
      nil ->
        changeset
        |> Ecto.Changeset.change(%{
          email_activation_token: gen_token()
        })

      _ ->
        changeset
    end
  end

  def email_changed(%Ecto.Changeset{} = changeset, %__MODULE__{} = user) do
    new_email = get_field(changeset, :email)

    cond do
      new_email != user.email ->
        changeset
        |> put_change(:email_verified, false)
        |> put_change(:email_activation_token, gen_token())

      true ->
        changeset
    end
  end

  defp gen_token(length \\ 16),
    do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)

  def full_name(%__MODULE__{firstname: first, lastname: last}), do: "#{first} #{last}"
end
