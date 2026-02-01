defmodule TCGOrders.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :name, :string
    field :item_number, :integer
    field :tags, {:array, :string}
    field :user_id, :binary_id
    belongs_to :order, TCGOrders.Orders.Order, foreign_key: :order_id, references: :id
    belongs_to :project, TCGOrders.Projects.Project, foreign_key: :project_id, references: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs, user_scope) do
    item
    |> cast(attrs, [:name, :item_number, :tags, :order_id, :project_id])
    |> validate_required([:name, :item_number, :order_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
