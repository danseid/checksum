defmodule Checksum.Crc do
  @moduledoc """
  CRC computation functions
  """

  use Bitwise
  import Checksum.Helpers
  alias Checksum.Crc, as: Crc

  defstruct [:width, :poly, :table, :init, :xor_out, :ref_in, :ref_out, :bits_mask, :top_bit]

  @doc """
  Initializes a `Crc` struct and compute a Crc table

  Args:

    * `width` - This is the width of the algorithm expressed in bits. This is one less than the width of the Poly.
    * `poly` - Value  of the poly (polynomial)
    * `init` -
    * `xor_out` -
    * `ref_in` -
    * `ref_out` -

  """
  def init(width \\ 8, poly \\ 0x7, init \\ 0x0, xor_out \\ 0x0, ref_in \\ false, ref_out \\ false) do

    %Crc{width: width, poly: poly, init: init, xor_out: xor_out, ref_in: ref_in, ref_out: ref_out}
    |> init_bits_mask
    |> init_top_bit
    |> init_crc_table
  end

  defp init_bits_mask(%Crc{width: width} = crc_params),  do: %Crc{crc_params | bits_mask: bits_mask(width)}
  defp init_top_bit(%Crc{width: width} = crc_params),  do: %Crc{crc_params | top_bit: top_bit(width)}

  defp init_crc_table(%Crc{} = crc_params) do
    table = 0..255
    |> Enum.map(&calc_crc_table_cell(crc_params, &1))

    %Crc{crc_params | table: table}
  end

  defp calc_crc_table_cell(%Crc{width: width, poly: poly, ref_in: ref_in, top_bit: top_bit, bits_mask: bits_mask}, dividend) do
   dividend
   |> reflect(8, ref_in)  # Reflect 8 bits if needed
   |> bsl(width-8)  # 
   |> bitwise_calc(0, top_bit, poly)
   |> reflect(width, ref_in)
   |> band(bits_mask)
  end


  defp bitwise_calc(remainder, 8, _top_bit, _poly), do: remainder
  defp bitwise_calc(remainder, bit, top_bit, poly) do
    case remainder &&& top_bit do
      0 -> remainder <<< 1 
      _ -> (remainder <<< 1) ^^^ poly
    end |> bitwise_calc(bit+1, top_bit, poly)
  end
end
