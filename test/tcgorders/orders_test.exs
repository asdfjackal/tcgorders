defmodule TCGOrders.OrdersTest do
  use TCGOrders.DataCase

  alias TCGOrders.Orders

  describe "orders" do
    alias TCGOrders.Orders.Order

    import TCGOrders.AccountsFixtures, only: [user_scope_fixture: 0]
    import TCGOrders.OrdersFixtures

    @invalid_attrs %{status: nil, order_id: nil, ordered_at: nil}

    test "list_orders/1 returns all scoped orders" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      other_order = order_fixture(other_scope)
      assert Orders.list_orders(scope) == [order]
      assert Orders.list_orders(other_scope) == [other_order]
    end

    test "get_order!/2 returns the order with given id" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      other_scope = user_scope_fixture()
      assert Orders.get_order!(scope, order.id) == order
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(other_scope, order.id) end
    end

    test "create_order/2 with valid data creates a order" do
      valid_attrs = %{status: "some status", order_id: "some order_id", ordered_at: ~D[2026-01-26]}
      scope = user_scope_fixture()

      assert {:ok, %Order{} = order} = Orders.create_order(scope, valid_attrs)
      assert order.status == "some status"
      assert order.order_id == "some order_id"
      assert order.ordered_at == ~D[2026-01-26]
      assert order.user_id == scope.user.id
    end

    test "create_order/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(scope, @invalid_attrs)
    end

    test "update_order/3 with valid data updates the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      update_attrs = %{status: "some updated status", order_id: "some updated order_id", ordered_at: ~D[2026-01-27]}

      assert {:ok, %Order{} = order} = Orders.update_order(scope, order, update_attrs)
      assert order.status == "some updated status"
      assert order.order_id == "some updated order_id"
      assert order.ordered_at == ~D[2026-01-27]
    end

    test "update_order/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)

      assert_raise MatchError, fn ->
        Orders.update_order(other_scope, order, %{})
      end
    end

    test "update_order/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(scope, order, @invalid_attrs)
      assert order == Orders.get_order!(scope, order.id)
    end

    test "delete_order/2 deletes the order" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert {:ok, %Order{}} = Orders.delete_order(scope, order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(scope, order.id) end
    end

    test "delete_order/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      order = order_fixture(scope)
      assert_raise MatchError, fn -> Orders.delete_order(other_scope, order) end
    end

    test "change_order/2 returns a order changeset" do
      scope = user_scope_fixture()
      order = order_fixture(scope)
      assert %Ecto.Changeset{} = Orders.change_order(scope, order)
    end
  end
end
