defmodule ExZigbee do
  use GenServer
  
  import ExZigbee.Helpers.String

  alias ExZigbee.Parser
  alias ExZigbee.FrameTypes.ExplicitTx

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, [name: ExZigbeeWorker])
  end

  def init(:ok) do
    config = Application.get_env(:ex_zigbee, :serial_config)
    
    {:ok, serial} = Serial.start_link

    Serial.open(serial, config[:port])
    Serial.set_speed(serial, config[:baud])

    sockets = Application.get_env(:ex_zigbee, :sockets, [])
    sockets = sockets |> Enum.map(fn socket_tuple -> ExZigbee.Socket.new(socket_tuple) end)

    {:ok, {serial, sockets, []}}
  end

  # Helper functions
  def send(to_tuple, payload) do
    GenServer.call(ExZigbeeWorker, {:send, to_tuple, payload})
  end

  # Handle from helpers
  def handle_call({:send, to_tuple, payload}, _from, {serial, _handlers, frame} = state) do   
    byte_string = ExplicitTx.create(to_tuple, payload)
    response = Serial.send_data(serial, byte_string)

    {:reply, response, state}
  end

  # Handle data from Serial reader
  def handle_info({:elixir_serial, serial, data}, {serial, sockets, frame}) do
    frame = Parser.Receiver.build_payload(frame, data) #get_codepoints(data))

    frame =
      case frame do
        {:complete, parsed_result} ->
          case parsed_result do
            {:error, message} -> IO.puts "An error occured: #{message}" # Handle errors properly
            {transport, frame} -> 
              sockets 
              |> Enum.filter(fn socket -> socket.transport == transport and
                                          socket.endpoint == frame.dest_endpoint and 
                                          socket.profile == frame.profile and 
                                          socket.cluster == frame.cluster end)
              |> Enum.each(fn socket -> socket.handler.(frame) end)
          end
        _ -> frame
      end

    {:noreply, {serial, sockets, frame}}
  end
end
