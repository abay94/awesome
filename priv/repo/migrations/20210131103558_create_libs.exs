defmodule Awesome.Repo.Migrations.CreateLibs do
  use Ecto.Migration

  def change do
    create table(:libs) do
      add :name, :string
      add :link, :string
      add :description, :text
      add :cnt_star, :integer
      add :cnt_days, :integer
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:libs, [:name])
    create index(:libs, [:group_id])
  end
end
