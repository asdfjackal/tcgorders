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

  def get_preview_uri(name) do
    search = URI.encode_www_form(name)
    uri = "https://api.scryfall.com/cards/search?q=" <> search

    case(Req.get(uri)) do
      {:ok, response} ->
        IO.inspect(name, label: "Searching Scryfall for")

        if Map.has_key?(response.body, "total_cards") do
          IO.inspect(Enum.map(response.body["data"], fn card -> card["name"] end),
            label: "Found Cards"
          )
        else
          IO.inspect("No cards found", label: "Scryfall Search Result")
        end

        cond do
          Map.has_key?(response.body, "total_cards") != true ->
            nil

          response.body["total_cards"] == 1 ->
            hd(response.body["data"])["image_uris"]["normal"]

          response.body["total_cards"] > 1 ->
            first_exact_match =
              Enum.find(response.body["data"], fn card ->
                String.downcase(card["name"]) == String.downcase(name)
              end)

            if first_exact_match do
              first_exact_match["image_uris"]["normal"]
            else
              nil
            end

          true ->
            nil
        end

      {:error, _} ->
        nil
    end
  end

  def transform_row_to_item(row, order) do
    scryfall_name =
      case Regex.run(~r/^[^\(]+/, row["Product Name"]) do
        [name | _] -> name
        nil -> nil
      end

    %{
      name: row["Product Name"],
      scryfall_name: scryfall_name,
      item_number: String.to_integer(row["Item Number"]),
      order_id: order.id
    }
  end

  def update_item_scryfall_image(item, scope) do
    if item.scryfall_name != nil do
      case get_preview_uri(item.scryfall_name) do
        nil -> :ok
        uri -> Items.update_item(scope, item, %{preview_uri: uri})
      end

      Process.sleep(200)
    end
  end

  def start_scryfall_fetcher(scope) do
    Task.Supervisor.start_child(TCGOrders.TaskSupervisor, fn ->
      items = Items.list_items(scope)

      Enum.map(items, fn item ->
        update_item_scryfall_image(item, scope)
      end)
    end)
  end

  def import_csv(csv, scope) do
    Enum.each(csv, fn row ->
      order_id = row["Order Id"]
      order = Orders.get_order_by_order_id(scope, order_id)

      {:ok, order} =
        if order do
          Orders.update_order(scope, order, transform_row_to_order(row))
        else
          Orders.create_order(scope, transform_row_to_order(row))
        end

      item = Items.get_item_by_order_and_number(scope, order.id, row["Item Number"])
      IO.inspect(transform_row_to_item(row, order), label: "Importing Item")

      if item do
        Items.update_item(scope, item, transform_row_to_item(row, order))
      else
        Items.create_item(scope, transform_row_to_item(row, order))
      end
    end)

    start_scryfall_fetcher(scope)
  end
end
