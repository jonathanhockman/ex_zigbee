defmodule ExZigbee do
  use Application

  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(ExZigbee.SerialWorker, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExZigbee.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)

    # Send one to self
    dest_addy = ExZigbee.Address.new(0x05, {0x01, 0x04}, {0x04, 0x02}, {0x0, 0x13, 0xA2, 0x0, 0x40, 0x99, 0x93, 0x58})
    ExZigbee.SerialWorker.send(dest_addy, ExZigbee.Helpers.String.get_codepoints("Just a test message to self."))

    # Send one to external device
    dest_addy = ExZigbee.Address.new(0x01, {0x01, 0x04}, {0x04, 0x02}, {0x0, 0x13, 0xA2, 0x0, 0x40, 0xE6, 0x5A, 0x6D})
    ExZigbee.SerialWorker.send(dest_addy, ExZigbee.Helpers.String.get_codepoints("Just a test message to external."))

    {:ok, sup_pid}
  end
end
