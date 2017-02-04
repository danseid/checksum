defmodule Checksum.Helpers do
  use Bitwise
  @doc """
  Reorder the `bits` of a binary sequence `value`, by reflecting them about the middle position.

  ## Examples

      iex> Checksum.Helpers.reflect(0x3E23, 3) == 0x3E26
      true

  """
  def reflect(value, bits), do: reflect(1, 1 <<< (bits-1), value, value)

  @doc """
  Conditional Reorder the bits of a binary sequence, by reflecting them about the middle position.
  If `bool` true the bits will be reflected, if it is false the input value will be returned. 

  ## Examples

      iex> Checksum.Helpers.reflect(0x3E23, 3, true) == 0x3E26
      true
      iex> Checksum.Helpers.reflect(0x3E23, 3, false) == 0x3E23
      true

  """
  def reflect(value, bits, true), do: reflect(value, bits)
  def reflect(value, _bits, false), do: value

  defp reflect(_src_bit, 0, _value, reflected), do: reflected # Recursion ends, if the destination bit is zero.
  defp reflect(src_bit, dst_bit, value, reflected) do
    reflected = case value &&& src_bit do
                  0 -> reflected &&& ~~~dst_bit
                  _ -> reflected ||| dst_bit
                end
    reflect(src_bit <<< 1, dst_bit >>> 1, value, reflected)
  end

  @doc """
  Calculates a bit mask of ones with a length of width.

  ## Examples

      iex> Checksum.Helpers.bits_mask(1) |> Integer.to_charlist(2)
      '1' 
      iex> Checksum.Helpers.bits_mask(4) |> Integer.to_charlist(2)
      '1111' 
      iex> Checksum.Helpers.bits_mask(8) |> Integer.to_charlist(2)
      '11111111' 

  """
  def bits_mask(width), do: (1 <<< width) - 1

  @doc """
  Calculates a top bit mask. 

  ## Examples

      iex> Checksum.Helpers.top_bit(1) |> Integer.to_charlist(2)
      '1' 
      iex> Checksum.Helpers.top_bit(4) |> Integer.to_charlist(2)
      '1000' 
      iex> Checksum.Helpers.top_bit(8) |> Integer.to_charlist(2)
      '10000000' 

  """
  def top_bit(width), do: 1 <<< (width - 1)

end
