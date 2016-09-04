# ExZigbee

## Installation

### Not available in Hex yet
For the time being in your mix.exs you can use
  `def deps do
    [{:ex_zigbee, git: <Git HTTPS url>, tag: <release tag>}]
  end`

## Setting up the serial connection
In your config.exs file add:
`config :ex_zigbee, :serial_config,
port: <path to serial port>,
baud: <baud rate>`

## Starting the service
In your application add:
`children = [
      # Start the endpoint when the application starts
      supervisor(ExZigbee, [])
    ]`

## Receiving messages
To Receive a message you must register a 'socket'. There are two ways to do this.

### config.exs
`config :ex_zigbee, :sockets, [
  {<endpoint>, <transport>, <callback>}
]`

### At runtime
To register a socket to listen on an endpoint simply use:
`socket = ExZigbee.Socket.new(<endpoint>, <transport>, <callback>)
ExZigbee.register_socket(socket)`

The callback will be called whenever a message is received for that endpoint.

## Sending messages
`ExZigbee.send(<socket>, <dest_address>, <payload>)`

Payloads are integer arrays, so if you want to send a string there is a
helper function called ExZigbee.Helpers.String.get_codepoints

## Transports
Right now only one type of transport(perhaps there's a better term. Frame type?) 
is supported and is defined in ExZigbee.Transport module as `:explicit`
