defmodule ExZigbee.Helpers.String do
  def get_string_for_16_bits({first, second}), do: to_string((first * 256) + second)
  def get_bitstring(tuple) when is_tuple(tuple), do: tuple |> Tuple.to_list |> get_bitstring
  def get_bitstring(list) when is_list(list), do: list |> Enum.map(fn e -> <<e>> end) |> Enum.join
  def get_bitstring(string) when is_bitstring(string), do: string |> String.get_codepoints |> get_bitstring

  # This function is purely to fix the built in String.codepoints
  # String.codepoints will still return a valid character with multiple
  # bytes instead of breaking them out byte by byte
  def get_codepoints(string), do: get_codepoints(string, [])
  def get_codepoints("", codepoints), do: List.flatten(codepoints)
  def get_codepoints(<<point::size(8)>> <> rest, codepoints) do

    # point = binary_part(string, 0, 1)
    # rest = binary_part(string, 1, byte_size(string) - 1)
    codepoints = [codepoints, point]
    get_codepoints(rest, codepoints)
  end
end