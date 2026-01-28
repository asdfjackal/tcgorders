defmodule TCGOrders.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :order_id, :string
    field :ordered_at, :date
    field :status, :string
    field :user_id, :binary_id
    field :received, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs, user_scope) do
    order
    |> cast(attrs, [:order_id, :ordered_at, :status, :received])
    |> validate_required([:order_id, :ordered_at, :status, :received])
    |> put_change(:user_id, user_scope.user.id)
  end
end
