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
  def send(socket, to, payload) do
    GenServer.cast(ExZigbeeWorker, {:send, socket, to, payload})
  end

  def register_socket(socket) do
    GenServer.call(ExZigbeeWorker, {:register_socket, socket})
  end

  def unregister_socket(socket) do
    GenServer.call(ExZigbeeWorker, {:register_socket, socket})
  end

  # Handle from helpers
  def handle_cast({:send, socket, to, payload}, {serial, _sockets, frame} = state) do
    byte_string =
      case socket.transport do
        :explicit -> {:ok, ExplicitTx.create(socket, to, payload)}
        transport -> {:error, "Unknown transport '#{transport}'."}
      end
    
    case byte_string do
      {:ok, payload} -> Serial.send_data(serial, payload)
      {:error, message} -> IO.puts message
    end

    {:noreply, state}
  end

  def handle_call({:register_socket, socket}, _from, {serial, sockets, frame}) do
    status =
      if socket.__struct__ == ExZigbee.Socket do
        sockets
        |> Enum.filter(fn s -> socket.endpoint == s.endpoint end)
        |> case do
          [] ->
            sockets = [socket] ++ sockets
            {:ok, socket}
          _ ->
            {:error, "You already have a socket registered for that endpoint."}
        end
      else
        {:error, "Socket must be of a ExZigbee.Socket struct."}
      end

    {:reply, status, {serial, sockets, frame}}
  end

  def handle_call({:unregister_socket, socket}, _from, {serial, sockets, frame}) do
    sockets = sockets |> Enum.filter(fn s -> s.endpoint != socket.endpoint end)

    {:reply, {:ok}, {serial, sockets, frame}}
  end

  # Handle data from Serial reader
  def handle_info({:elixir_serial, serial, data}, {serial, sockets, frame}) do
    frame = Parser.Receiver.build_payload(frame, data) #get_codepoints(data))

    frame =
      case frame do
        {:complete, parsed_result} ->
          case parsed_result do
            {:error, message} -> IO.puts "An error occured: #{message}" # Handle errors properly
            {transport, {endpoint, src_address, payload}} -> 
              sockets 
              |> Enum.filter(fn socket -> socket.transport == transport and
                                          socket.endpoint == endpoint end)
              |> Enum.each(fn socket -> socket.handler.({socket, src_address, payload}) 
              end)
          end
        _ -> frame
      end

    {:noreply, {serial, sockets, frame}}
  end
end
