defmodule Awesome.Context.Lib do
  use Ecto.Schema
  import Ecto.Changeset
  alias Awesome.Context.Group

  schema "libs" do
    field :cnt_days, :integer
    field :cnt_star, :integer
    field :description, :string
    field :link, :string
    field :name, :string
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(lib, attrs) do
    lib
    |> cast(attrs, [:name, :link, :desc, :cnt_star, :cnt_days])
    |> validate_required([:name, :link, :desc, :cnt_star, :cnt_days])
    |> unique_constraint(:name)
  end
end
