defmodule TCGOrders.Repo.Migrations.AddItemNumber do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :item_number, :integer
    end
  end
end
