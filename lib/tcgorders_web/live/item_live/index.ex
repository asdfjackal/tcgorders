defmodule TCGOrdersWeb.ItemLive.Index do
  use TCGOrdersWeb, :live_view

  alias TCGOrders.Items

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Items
        <:actions>
          <.button variant="primary" navigate={~p"/items/new"}>
            <.icon name="hero-plus" /> New Item
          </.button>
        </:actions>
      </.header>

      <.table
        id="items"
        rows={@streams.items}
        row_click={fn {_id, item} -> JS.navigate(~p"/items/#{item}") end}
      >
        <:col :let={{_id, item}} label="Name">{item.name}</:col>
        <:col :let={{_id, item}} label="Tags">{item.tags}</:col>
        <:action :let={{_id, item}}>
          <div class="sr-only">
            <.link navigate={~p"/items/#{item}"}>Show</.link>
          </div>
          <.link navigate={~p"/items/#{item}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, item}}>
          <.link
            phx-click={JS.push("delete", value: %{id: item.id}) |> hide("##{id}")}
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
      Items.subscribe_items(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Items")
     |> stream(:items, list_items(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Items.get_item!(socket.assigns.current_scope, id)
    {:ok, _} = Items.delete_item(socket.assigns.current_scope, item)

    {:noreply, stream_delete(socket, :items, item)}
  end

  @impl true
  def handle_info({type, %TCGOrders.Items.Item{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :items, list_items(socket.assigns.current_scope), reset: true)}
  end

  defp list_items(current_scope) do
    Items.list_items(current_scope)
  end
end
