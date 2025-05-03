defmodule Assessment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AssessmentWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:assessment, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Assessment.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Assessment.Finch},
      # Start a worker by calling: Assessment.Worker.start_link(arg)
      # {Assessment.Worker, arg},
      # Start to serve requests, typically the last entry
      AssessmentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Assessment.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AssessmentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
