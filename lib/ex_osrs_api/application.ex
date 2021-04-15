defmodule ExOsrsApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # GenServer.start_link(
    #   ExRated,
    #   [{:timeout, 10_000}, {:cleanup_rate, 10_000}, {:persistent, false}],
    #   name: :ex_rated
    # )

    children = [
      # Starts a worker by calling: ExOsrsApi.Worker.start_link(arg)
      # {ExOsrsApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExOsrsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
