defmodule ExZigbee.Address do
  defstruct endpoint: nil,
            profile: nil,
            cluster: nil,
            extended_address: nil,
            short_address: nil

  def new(endpoint, profile, cluster, extended_address, short_address) when is_integer(endpoint) and is_tuple(profile) and is_tuple(cluster) and is_tuple(extended_address) and is_tuple(short_address) do
    %__MODULE__{endpoint: endpoint, profile: profile, cluster: cluster, extended_address: extended_address, short_address: short_address}
  end
  def new(endpoint, profile, cluster, address) when is_integer(endpoint) and is_tuple(profile) and is_tuple(cluster) and is_tuple(address) do
      case tuple_size(address) do
        2 -> new(endpoint, profile, cluster, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff}, address)
        8 -> new(endpoint, profile, cluster, address, {0xff, 0xfe})
      end
  end
end