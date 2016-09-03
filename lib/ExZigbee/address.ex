defmodule ExZigbee.Address do
  defstruct endpoint: nil,
            profile: nil,
            cluster: nil,
            long_address: nil

  def new(endpoint, profile, cluster, long_address) when is_integer(endpoint) and is_tuple(profile) and is_tuple(cluster) and is_tuple(long_address) do
    %__MODULE__{endpoint: endpoint, profile: profile, cluster: cluster, long_address: long_address}
  end
end