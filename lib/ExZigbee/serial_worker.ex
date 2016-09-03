defmodule ExZigbee.SerialWorker do
  use GenServer
  import ExZigbee.Helpers.String

  alias ExZigbee.Parser
  alias ExZigbee.FrameTypes.ExplicitTx

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, [name: ExZigbeeSerialWorker])
  end

  def init(:ok) do
    config = Application.get_env(:ex_zigbee, :serial_config)
    
    {:ok, serial} = Serial.start_link

    Serial.open(serial, config[:port])
    Serial.set_speed(serial, config[:baud])

    raw_handlers = Application.get_env(:ex_zigbee, :handlers, [])
    handlers = build_handler_map(raw_handlers)

    {:ok, {serial, handlers, []}}
  end

  # Helper functions
  def send(to_tuple, payload) do
    GenServer.call(ExZigbeeSerialWorker, {:send, to_tuple, payload})
  end

  # Handle from helpers
  def handle_call({:send, to_tuple, payload}, _from, {serial, _handlers, frame} = state) do   
    byte_string = ExplicitTx.create(to_tuple, payload)
    response = Serial.send_data(serial, byte_string)

    {:reply, response, state}
  end

  # Handle data from Serial reader
  def handle_info({:elixir_serial, serial, data}, {serial, handlers, frame}) do
    frame = Parser.Receiver.build_payload(frame, data) #get_codepoints(data))

    frame =
      case frame do
        {:complete, frame} ->
          key = get_key_for_callback(frame.dest_endpoint, frame.profile, frame.cluster)

          handlers 
          |> Map.get(key, [])
          |> Enum.each(fn callback -> callback.(frame) end)
        _ -> frame
      end

    {:noreply, {serial, handlers, frame}}
  end

  def get_key_for_callback(endpoint, profile, cluster) do
    to_string(endpoint) <> to_string(get_string_for_16_bits(profile)) <> to_string(get_string_for_16_bits(cluster))
  end

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
end
