defmodule TCGOrdersWeb.OrderLive.Index do
  use TCGOrdersWeb, :live_view

  alias TCGOrders.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Orders
        <:actions>
          <.button variant="primary" navigate={~p"/orders/new"}>
            <.icon name="hero-plus" /> New Order
          </.button>
        </:actions>
      </.header>

      <.table
        id="orders"
        rows={@streams.orders}
        row_click={fn {_id, order} -> JS.navigate(~p"/orders/#{order}") end}
      >
        <:col :let={{_id, order}} label="Order">{order.order_id}</:col>
        <:col :let={{_id, order}} label="Ordered at">{order.ordered_at}</:col>
        <:col :let={{_id, order}} label="Status">{order.status}</:col>
        <:action :let={{_id, order}}>
          <div class="sr-only">
            <.link navigate={~p"/orders/#{order}"}>Show</.link>
          </div>
          <.link navigate={~p"/orders/#{order}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, order}}>
          <.link
            phx-click={JS.push("delete", value: %{id: order.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Orders.subscribe_orders(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Orders")
     |> stream(:orders, list_orders(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Orders.get_order!(socket.assigns.current_scope, id)
    {:ok, _} = Orders.delete_order(socket.assigns.current_scope, order)

    {:noreply, stream_delete(socket, :orders, order)}
  end

  @impl true
  def handle_info({type, %TCGOrders.Orders.Order{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :orders, list_orders(socket.assigns.current_scope), reset: true)}
  end

  defp list_orders(current_scope) do
    Orders.list_orders(current_scope)
  end
end
