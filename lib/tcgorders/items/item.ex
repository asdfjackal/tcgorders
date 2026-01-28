defmodule TCGOrders.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :name, :string
    field :item_number, :integer
    field :tags, {:array, :string}
    field :order_id, :binary_id
    field :project_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs, user_scope) do
    item
    |> cast(attrs, [:name, :item_number, :tags])
    |> validate_required([:name, :item_number])
    |> put_change(:user_id, user_scope.user.id)
  end
end
