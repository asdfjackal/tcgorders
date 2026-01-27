defmodule TCGOrders.Repo do
  use Ecto.Repo,
    otp_app: :tcgorders,
    adapter: Ecto.Adapters.Postgres
end
