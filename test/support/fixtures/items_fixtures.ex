defmodule TCGOrders.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TCGOrders.Items` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        tags: ["option1", "option2"]
      })

    {:ok, item} = TCGOrders.Items.create_item(scope, attrs)
    item
  end
end
