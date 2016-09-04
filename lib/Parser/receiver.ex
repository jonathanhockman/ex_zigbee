defmodule ExZigbee.Parser.Receiver do
  
  alias ExZigbee.FrameTypes.{ExplicitRx}

  def build_payload(data, <<single::size(8)>>), do: check_byte(data, single)
  def build_payload(data, <<first::size(8)>> <> rest) do
    data = check_byte(data, first)
    build_payload(data, rest)
  end

  def check_byte(data, byte) do
    data =
      case data do
        [0x7e, first, second | rest] -> 
          length = (first * 256) + second

          case Enum.count(rest) do
            ^length ->
              frame =
                if _verify_checksum(rest, byte) do
                  _parse_frame(data)
                else
                  {:error, "Checksum failed"}
                end

              {:complete, frame}
            _ -> data
          end
        _ -> data
      end

    case data do
      {:complete, frame} -> {:complete, frame}
      _ -> case byte do
          0x7e -> [byte]
          _ -> List.flatten([data, byte])
        end
    end
  end

  defp _parse_frame([_header, _lfirst, _lsecond, frame_type | frame_data]) do
    case frame_type do
      0x91 -> {ExZigbee.Transport.explicit, ExplicitRx.parse(frame_data)}
      _ -> 
        string_type = Base.encode16(<<frame_type>>)
        {:error, "Unsupported frame type: 0x#{string_type}"}
    end
  end

  defp _verify_checksum(data, checksum) do
    checksum == ExZigbee.Helpers.Frames.calculate_checksum(data)
  end
end