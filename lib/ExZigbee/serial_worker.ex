defmodule ExZigbee.SerialWorker do
  use Bitwise, skip_operators: true

  alias ExZigbee.FrameTypes

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, {:ok, opts}, [])
  end

  def init({:ok, opts}) do
    config = Application.get_env(:ex_zigbee, :serial_config)

    {:ok, serial} = Serial.start_link

    Serial.open(serial, config[:port])
    Serial.set_speed(serial, config[:baud])

    handlers = build_handler_map(opts)

    {:ok, {handlers, []}}
  end

  def handle_info({:elixir_serial, serial, data}, {handlers, frame}) do
    frame = build_payload(frame, get_codepoints(data))

    frame =
      case frame do
        {:complete, frame} ->
          key = get_key_for_callback(frame.dest_endpoint, frame.profile, frame.cluster)

          handlers 
          |> Map.get(key, [])
          |> Enum.each(fn callback -> callback.(frame) end)
        _ -> frame
      end

    {:noreply, {handlers, frame}}
  end

  def get_key_for_callback(endpoint, profile, cluster) do
    to_string(endpoint) <> to_string(get_string_for_16_bits(profile)) <> to_string(get_string_for_16_bits(cluster))
  end

  def get_string_for_16_bits({first, second}), do: to_string((first * 256) + second)

  def build_handler_map(handlers), do: build_handler_map(handlers, %{})
  def build_handler_map([], handlers), do: handlers
  def build_handler_map([{endpoint, profile, cluster, callback} | rest], handlers) do
    key = get_key_for_callback(endpoint, profile, cluster)
    handlers = handlers |> Map.put_new(key, [])
    callbacks = handlers |> Map.get(key)
    callbacks = List.flatten([callbacks, callback])
    handlers = handlers |> Map.put(key, callbacks)
    build_handler_map(rest, handlers)
  end

  # This function is purely to fix the built in String.codepoints
  # String.codepoints will still return a valid character with multiple
  # bytes instead of breaking them out byte by byte
  def get_codepoints(string), do: get_codepoints(string, [])
  def get_codepoints("", codepoints), do: List.flatten(codepoints)
  def get_codepoints(string, codepoints) do
    point = binary_part(string, 0, 1)
    rest = binary_part(string, 1, byte_size(string) - 1)
    codepoints = [codepoints, point]
    get_codepoints(rest, codepoints)
  end

  def build_payload(data, [<<single>>]), do: check_byte(data, single)
  def build_payload(data, [<<first>> | rest]) do
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
                unless not _verify_checksum(rest, byte) do
                  _parse_frame(data, byte)  
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

  defp _parse_frame([_header, _lfirst, _lsecond, frame_type | frame_data], checksum) do
    case frame_type do
      0x91 -> FrameTypes.ExplicitRx.parse(frame_data, checksum)
      _ -> 
        IO.puts "Unsupported frame type: "
        IO.inspect frame_type, base: :hex
        IO.inspect frame_data, base: :hex
        IO.puts "checksum: " <> to_string(checksum)
    end
  end

  defp _verify_checksum(data, checksum) do
    total = 
      data
      |> Enum.reduce(0, &(&1 + &2))
      |> band(0xff)
      |> rem(256)

    (0xff - total) == checksum
  end

  defp _add_data_payload([], total \\ 0), do: total
  defp _add_data_payload([first | rest], total) do
    total = total + first
  end
end
