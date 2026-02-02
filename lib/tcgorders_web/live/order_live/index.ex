defmodule TCGOrdersWeb.OrderLive.Index do
  use TCGOrdersWeb, :live_view

  import Ecto.Changeset

  alias TCGOrders.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Orders
      </.header>
      <label class="input w-full">
        <svg class="h-[1em] opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <g
            stroke-linejoin="round"
            stroke-linecap="round"
            stroke-width="2.5"
            fill="none"
            stroke="currentColor"
          >
            <circle cx="11" cy="11" r="8"></circle>
            <path d="m21 21-4.3-4.3"></path>
          </g>
        </svg>
        <.form
          for={@form}
          id="import-form"
          phx-change="search"
          phx-submit="search"
        >
          <input
            id={@form[:search].id}
            name={@form[:search].name}
            value={@form[:search].value}
            phx-debounce="1000"
            type="search"
            placeholder="Search"
            label="Raw CSV"
          />
        </.form>
      </label>
      <div :for={{_, order} <- @streams.orders} class="card card-border bg-base-100 w-full">
        <div class="card-body">
          <div class="card-title flex items-start">
            <div class="flex-1">
              <span>{order.ordered_at}</span>
              <span> -  {Orders.get_order_status(order)}</span>
            </div>
            <div class="flex-none">
              <span class="font-normal text-xs">{order.order_id}</span>
            </div>
          </div>
          <div class="divider m-0"></div>
          <ul>
            <li :for={item <- order.items}>
              <%= if item.preview_uri do %>
                <div class="tooltip tooltip-right">
                  <div class="tooltip-content">
                    <image src={item.preview_uri} />
                    <%!-- <image src="https://cards.scryfall.io/normal/front/1/0/101d22c6-830d-4908-9003-6b206f694eba.jpg?1738356526" /> --%>
                  </div>
                  {item.name}
                </div>
              <% else %>
                <span>{item.name}</span>
              <% end %>
            </li>
          </ul>
          <div class="card-actions justify-end">
            <span
              phx-click="received_toggle"
              phx-value-id={order.id}
              class={["btn", if(order.received, do: "btn-error", else: "btn-success")]}
            >
              {if order.received, do: "Not Delivered", else: "Delivered"}
            </span>
            <.link class="btn btn-primary" navigate={~p"/orders/#{order}"}>Show</.link>
            <.link class="btn btn-primary" navigate={~p"/orders/#{order}/edit"}>Edit</.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @types %{
    search: :string
  }

  def changeset(data, params) do
    # Start with a data-types tuple (equivalent to a struct in a schemaless context)
    {data, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:search])
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Orders.subscribe_orders(socket.assigns.current_scope)
    end

    data = %{search: ""}
    params = %{search: ""}
    changeset = changeset(data, params)

    {:ok,
     socket
     |> assign(:page_title, "Listing Orders")
     |> stream(:orders, list_orders(socket.assigns.current_scope))
     |> assign(:form, to_form(changeset, as: "search-form"))}
  end

  @impl true
  def handle_event("search", %{"search-form" => import_params}, socket) do
    changeset = changeset(%{search: ""}, import_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate, as: "search-form"))
     |> stream(:orders, list_orders(socket.assigns.current_scope, import_params["search"]))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Orders.get_order!(socket.assigns.current_scope, id)
    {:ok, _} = Orders.delete_order(socket.assigns.current_scope, order)

    {:noreply, stream_delete(socket, :orders, order)}
  end

  @impl true
  def handle_event("received_toggle", %{"id" => id}, socket) do
    order = Orders.get_order!(socket.assigns.current_scope, id)

    {:ok, _order} =
      Orders.update_order(
        socket.assigns.current_scope,
        order,
        %{received: !order.received}
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({type, %TCGOrders.Orders.Order{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :orders, list_orders(socket.assigns.current_scope), reset: true)}
  end

  defp list_orders(current_scope, search) do
    Orders.list_orders_with_items(current_scope, search)
  end

  defp list_orders(current_scope) do
    Orders.list_orders_with_items(current_scope, "")
  end
end
