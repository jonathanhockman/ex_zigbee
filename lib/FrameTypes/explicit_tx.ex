defmodule ExZigbee.FrameTypes.ExplicitTx do

  alias ExZigbee.Helpers

  def create(socket, to, payload) when is_list(payload) do
    payload = [0x11,
              0x00,
              Tuple.to_list(to.extended_address), 
              Tuple.to_list(to.short_address),
              socket.endpoint,
              to.endpoint,
              Tuple.to_list(to.cluster),
              Tuple.to_list(to.profile),
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