defmodule TCGOrders.Repo.Migrations.AddScryfallPreviewFields do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :scryfall_name, :string
      add :preview_uri, :string
    end
  end
end
