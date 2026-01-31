defmodule TCGOrdersWeb.ImportLive.Index do
  use TCGOrdersWeb, :live_view

  import Ecto.Changeset

  alias TCGOrders.Orders
  alias TCGOrders.Items

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Import Order History
        <:subtitle>Use this form to import a csv of your order history.</:subtitle>
      </.header>

      <.form for={@form} id="import-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:csv]} type="textarea" label="Raw CSV" />
        <footer>
          <.button phx-disable-with="Importing..." variant="primary">Import Order History</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @types %{
    csv: :string
  }

  def changeset(data, params) do
    # Start with a data-types tuple (equivalent to a struct in a schemaless context)
    {data, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:csv])
  end

  @impl true
  def mount(_params, _session, socket) do
    data = %{csv: ""}
    params = %{csv: ""}
    changeset = changeset(data, params)

    {:ok,
     socket
     |> assign(:form, to_form(changeset, as: "import-form"))}
  end

  @impl true
  def handle_event("validate", %{"import-form" => import_params}, socket) do
    changeset = changeset(%{csv: ""}, import_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate, as: "import-form"))}
  end

  @impl true
  def handle_event("save", %{"import-form" => import_params}, socket) do
    csv = parse_csv(import_params["csv"])
    import_csv(csv, socket.assigns.current_scope)

    {:noreply, push_navigate(socket, to: ~p"/orders")}
  end

  def parse_csv(raw_csv) do
    [raw_csv]
    |> CSV.decode!(headers: true, separator: ?\t)
  end

  def transform_row_to_order(row) do
    %{
      order_id: row["Order Id"],
      ordered_at: Date.from_iso8601!(row["Ordered At"]),
      status: row["Shipping Status"]
    }
  end

  def transform_row_to_item(row, order) do
    %{
      name: row["Product Name"],
      item_number: String.to_integer(row["Item Number"]),
      order_id: order.id
    }
  end

  def import_csv(csv, scope) do
    Enum.each(csv, fn row ->
      IO.inspect(row, label: "Importing row")
      order_id = row["Order Id"]
      order = Orders.get_order_by_order_id(scope, order_id)

      {:ok, order} =
        if order do
          Orders.update_order(scope, order, transform_row_to_order(row))
        else
          Orders.create_order(scope, transform_row_to_order(row))
        end

      item = Items.get_item_by_order_and_number(scope, order.id, row["Item Number"])

      if item do
        Items.update_item(scope, item, transform_row_to_item(row, order))
      else
        Items.create_item(scope, Map.put(transform_row_to_item(row, order), :order_id, order.id))
      end
    end)
  end
end
