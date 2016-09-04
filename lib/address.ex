defmodule ExZigbee.Address do
  defstruct endpoint: nil, # integer
            profile: nil, # tuple ex. {0x01, 0x04} for home automation
            cluster: nil, # tuple ex. {0x02, 0x04} for thermostat
            extended_address: nil, # tuple ex. {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff}
            short_address: nil # tuple ex. {0xff, 0xfe}

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