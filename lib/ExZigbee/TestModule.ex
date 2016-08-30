defmodule ExZigbee.TestModule do
  def test_function(frame) do
    IO.puts "Source Address"
    IO.inspect frame.src_ext_address, binaries: :as_binaries, base: :hex
    IO.puts "Source Short"
    IO.inspect frame.src_short_address, binaries: :as_binaries, base: :hex
    IO.puts "Source Endpoint"
    IO.inspect frame.src_endpoint, base: :hex
    IO.puts "Destination Endpoint"
    IO.inspect frame.dest_endpoint, base: :hex
    IO.puts "Cluster"
    IO.inspect frame.cluster, base: :hex
    IO.puts "Profile"
    IO.inspect frame.profile, base: :hex
    IO.puts "Payload"
    IO.inspect frame.payload
  end
end