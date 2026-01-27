defmodule TCGOrders.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TCGOrders.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        order_id: "some order_id",
        ordered_at: ~D[2026-01-26],
        status: "some status"
      })

    {:ok, order} = TCGOrders.Orders.create_order(scope, attrs)
    order
  end
end
