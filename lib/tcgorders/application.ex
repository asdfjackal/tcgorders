defmodule TCGOrders.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TCGOrdersWeb.Telemetry,
      TCGOrders.Repo,
      {DNSCluster, query: Application.get_env(:tcgorders, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TCGOrders.PubSub},
      # Start a worker by calling: TCGOrders.Worker.start_link(arg)
      # {TCGOrders.Worker, arg},
      # Start to serve requests, typically the last entry
      TCGOrdersWeb.Endpoint,
      {Task.Supervisor, name: TCGOrders.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TCGOrders.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TCGOrdersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
