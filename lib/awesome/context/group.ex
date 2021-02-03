defmodule Awesome.Context.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Awesome.Context.Lib

  schema "groups" do
    field :name, :string
    field :anchor, :string
    field :description, :string
    has_many :lib, Lib

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name,:anchor])
    |> validate_required([:name,:anchor])
    |> unique_constraint(:name)
  end
end
