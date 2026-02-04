defmodule TCGOrdersWeb.ItemLive.AssignProject do
  use TCGOrdersWeb, :live_view

  alias TCGOrders.Items
  alias TCGOrders.Projects
  alias TCGOrders.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <h2 class="font-bold">{@item.name}</h2>
        <small :if={@item.project} class="font-sm">
          Currently in collection
          <.link navigate={~p"/projects/#{@item.project}"}>{@item.project.name}</.link>
        </small>
      </.header>

      <%= if length(@item.order.items) > 1 do %>
        <h2 class="font-bold">In order with following other items:</h2>
        <ul class="list-disc list-inside">
          <li :for={item <- @item.order.items} :if={item.id != @item.id}>
            <.link navigate={~p"/items/#{item}"}>
              {item.name}<em class="font-italics">{if item.project do
                " - " <> item.project.name
              end}</em>
            </.link>
          </li>
        </ul>
      <% end %>

      <.table id="projects" rows={@projects}>
        <:col :let={project} label="Name">{project.name}</:col>
        <:col :let={project}>
          <button
            phx-click="assign"
            disabled={@item.project && project.id == @item.project.id}
            phx-value-project={project.id}
            class="btn btn-primary"
          >
            {if @item.project && project.id == @item.project.id do
              "Current Project"
            else
              "Set Project"
            end}
          </button>
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp get_item!(scope, id) do
    Items.get_item!(scope, id)
    |> Repo.preload([:project, order: [items: [:project]]])
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    item =
      get_item!(socket.assigns.current_scope, id)

    IO.inspect(item, label: "Loaded item for assignment")

    projects =
      Projects.list_projects(socket.assigns.current_scope)

    socket
    |> assign(:item, item)
    |> assign(:projects, projects)
  end

  @impl true
  def handle_event("assign", %{"project" => project_id}, socket) do
    item = socket.assigns.item
    scope = socket.assigns.current_scope
    project = Projects.get_project!(scope, project_id)
    IO.inspect(project, label: "Assigning to project")

    {:ok, item} =
      Items.update_item(scope, item, %{project_id: project.id})

    IO.inspect(item, label: "Updated item")

    item =
      get_item!(socket.assigns.current_scope, item.id)

    {:noreply,
     socket
     |> assign(:item, item)}
  end
end
