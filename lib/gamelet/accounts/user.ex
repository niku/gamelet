defmodule Gamelet.Accounts.User do
  @moduledoc """
  Provides a User in the Account context.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Gamelet.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
