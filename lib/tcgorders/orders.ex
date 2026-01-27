defmodule TCGOrders.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias TCGOrders.Repo

  alias TCGOrders.Orders.Order
  alias TCGOrders.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any order changes.

  The broadcasted messages match the pattern:

    * {:created, %Order{}}
    * {:updated, %Order{}}
    * {:deleted, %Order{}}

  """
  def subscribe_orders(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(TCGOrders.PubSub, "user:#{key}:orders")
  end

  defp broadcast_order(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(TCGOrders.PubSub, "user:#{key}:orders", message)
  end

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders(scope)
      [%Order{}, ...]

  """
  def list_orders(%Scope{} = scope) do
    Repo.all_by(Order, user_id: scope.user.id)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(scope, 123)
      %Order{}

      iex> get_order!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(%Scope{} = scope, id) do
    Repo.get_by!(Order, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(scope, %{field: value})
      {:ok, %Order{}}

      iex> create_order(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(%Scope{} = scope, attrs) do
    with {:ok, order = %Order{}} <-
           %Order{}
           |> Order.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_order(scope, {:created, order})
      {:ok, order}
    end
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(scope, order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(scope, order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Scope{} = scope, %Order{} = order, attrs) do
    true = order.user_id == scope.user.id

    with {:ok, order = %Order{}} <-
           order
           |> Order.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_order(scope, {:updated, order})
      {:ok, order}
    end
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(scope, order)
      {:ok, %Order{}}

      iex> delete_order(scope, order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Scope{} = scope, %Order{} = order) do
    true = order.user_id == scope.user.id

    with {:ok, order = %Order{}} <-
           Repo.delete(order) do
      broadcast_order(scope, {:deleted, order})
      {:ok, order}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(scope, order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Scope{} = scope, %Order{} = order, attrs \\ %{}) do
    true = order.user_id == scope.user.id

    Order.changeset(order, attrs, scope)
  end
end
