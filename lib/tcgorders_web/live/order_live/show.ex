defmodule TCGOrdersWeb.OrderLive.Show do
  use TCGOrdersWeb, :live_view

  alias TCGOrders.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Order {@order.id}
        <:subtitle>This is a order record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/orders"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/orders/#{@order}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit order
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Order">{@order.order_id}</:item>
        <:item title="Ordered at">{@order.ordered_at}</:item>
        <:item title="Status">{@order.status}</:item>
        <:item title="Received">{@order.received}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Orders.subscribe_orders(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Order")
     |> assign(:order, Orders.get_order!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %TCGOrders.Orders.Order{id: id} = order},
        %{assigns: %{order: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :order, order)}
  end

  def handle_info(
        {:deleted, %TCGOrders.Orders.Order{id: id}},
        %{assigns: %{order: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current order was deleted.")
     |> push_navigate(to: ~p"/orders")}
  end

  def handle_info({type, %TCGOrders.Orders.Order{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
