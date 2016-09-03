defmodule ExZigbee.FrameTypes.ExplicitTx do

  alias ExZigbee.Helpers

  def create({endpoint, profile, cluster, address}, payload) when is_list(payload) do
    payload = [0x11,
              0x00,
              Tuple.to_list(address), 
              0xff, 0xfe,
              0x05,
              endpoint,
              Tuple.to_list(cluster),
              Tuple.to_list(profile),
              0x00,
              0x00,
              payload]
    payload = List.flatten(payload)

    length = <<Enum.count(payload)::size(16)>>
    checksum = <<Helpers.Frames.calculate_checksum(payload)::size(8)>>
    payload = Helpers.String.get_bitstring(payload)

    <<0x7e>> <> length <> payload <> checksum
  end
end