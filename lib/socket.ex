defmodule ExZigbee.Socket do
  defstruct endpoint: nil,
            profile: nil,
            cluster: nil,
            transport: nil,
            handler: nil

  def new({endpoint, profile, cluster, transport, handler}), do: new(endpoint, profile, cluster, transport, handler)
  def new(endpoint, profile, cluster, transport, handler) do
    %ExZigbee.Socket{endpoint: endpoint, profile: profile, cluster: cluster, transport: transport, handler: handler}
  end
end