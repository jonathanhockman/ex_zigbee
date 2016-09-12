defmodule ExZigbee.Socket do
  defstruct endpoint: nil,
            transport: nil,
            handler: nil,
            profile: nil,
            cluster: nil,
            extended_address: nil,
            short_address: nil

  def new({endpoint, transport, handler}), do: new(endpoint, transport, handler)
  def new(endpoint, transport, handler) do
    %ExZigbee.Socket{endpoint: endpoint, transport: transport, handler: handler}
  end
end