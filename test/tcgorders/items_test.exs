defmodule TCGOrders.ItemsTest do
  use TCGOrders.DataCase

  alias TCGOrders.Items

  describe "items" do
    alias TCGOrders.Items.Item

    import TCGOrders.AccountsFixtures, only: [user_scope_fixture: 0]
    import TCGOrders.ItemsFixtures

    @invalid_attrs %{name: nil, tags: nil}

    test "list_items/1 returns all scoped items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      other_item = item_fixture(other_scope)
      assert Items.list_items(scope) == [item]
      assert Items.list_items(other_scope) == [other_item]
    end

    test "get_item!/2 returns the item with given id" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Items.get_item!(scope, item.id) == item
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(other_scope, item.id) end
    end

    test "create_item/2 with valid data creates a item" do
      valid_attrs = %{name: "some name", tags: ["option1", "option2"]}
      scope = user_scope_fixture()

      assert {:ok, %Item{} = item} = Items.create_item(scope, valid_attrs)
      assert item.name == "some name"
      assert item.tags == ["option1", "option2"]
      assert item.user_id == scope.user.id
    end

    test "create_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.create_item(scope, @invalid_attrs)
    end

    test "update_item/3 with valid data updates the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      update_attrs = %{name: "some updated name", tags: ["option1"]}

      assert {:ok, %Item{} = item} = Items.update_item(scope, item, update_attrs)
      assert item.name == "some updated name"
      assert item.tags == ["option1"]
    end

    test "update_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)

      assert_raise MatchError, fn ->
        Items.update_item(other_scope, item, %{})
      end
    end

    test "update_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Items.update_item(scope, item, @invalid_attrs)
      assert item == Items.get_item!(scope, item.id)
    end

    test "delete_item/2 deletes the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:ok, %Item{}} = Items.delete_item(scope, item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(scope, item.id) end
    end

    test "delete_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      assert_raise MatchError, fn -> Items.delete_item(other_scope, item) end
    end

    test "change_item/2 returns a item changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert %Ecto.Changeset{} = Items.change_item(scope, item)
    end
  end
end
