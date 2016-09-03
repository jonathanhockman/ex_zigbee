defmodule ExZigbee.Helpers.Frames do
  use Bitwise, skip_operators: true
  
  def calculate_checksum(data) do
    total = 
      data
      |> Enum.reduce(0, &(&1 + &2))
      |> band(0xff)
      |> rem(256)

    (0xff - total)
  end
end