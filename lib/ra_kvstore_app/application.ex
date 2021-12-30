defmodule RaKvstoreApp.Application do
  # See https://hexdos.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: RaKvstore.Worker.start_link(arg)
      # {RaKvstore.Worker, arg}
    ]

    :ra.start()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RaKvstore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
