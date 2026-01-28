defmodule TCGOrders.Repo.Migrations.AddOrderReceivedField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :received, :boolean, default: false, null: false
    end
  end
end
