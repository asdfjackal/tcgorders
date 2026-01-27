defmodule TCGOrders.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :tags, {:array, :string}
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:items, [:user_id])

    create index(:items, [:order_id])
    create index(:items, [:project_id])
  end
end
