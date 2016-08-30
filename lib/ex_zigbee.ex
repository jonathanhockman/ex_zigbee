defmodule ExZigbee do
  use Application

  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(ExZigbee.SerialWorker, [
        [{0x05, {0x01, 0x04}, {0x04, 0x02}, fn params -> ExZigbee.TestModule.test_function(params) end}]
      ])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExZigbee.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)
  end
end
