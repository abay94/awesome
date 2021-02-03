defmodule Awesome.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Awesome.Repo,
      # Start the Telemetry supervisor
      AwesomeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Awesome.PubSub},
      # Start the Endpoint (http/https)
      AwesomeWeb.Endpoint,
      # Start a worker by calling: Awesome.Worker.start_link(arg)
      # {Awesome.Worker, arg}
      Awesome.Context.JobServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Awesome.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
