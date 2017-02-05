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
  def init(width, poly, init, xor_out, ref_in, ref_out) do

    %Crc{width: width, poly: poly, init: init, xor_out: xor_out, ref_in: ref_in, ref_out: ref_out}
    |> init_bits_mask
    |> init_top_bit
    |> init_crc_table
  end

  def init(:crc_8), do: init(8, 0x07, 0x00, 0x00, false, false)
  def init(:crc_16), do: init(16, 0x8005, 0x000, 0x000, true, true)
  def init(:arc), do: init(:crc_16)

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

  def calc(%Crc{init: init, ref_in: ref_in, width: width} = params, data), do: calc(params, reflect(init, width, ref_in), data)

  defp calc(%Crc{table: table, ref_in: ref_in, width: width} = params, last_crc, <<h, t :: binary>>) do
    {crc, index} = case ref_in do
       true ->  {last_crc >>> 8, last_crc ^^^ h}
       false -> {last_crc <<< 8, (last_crc >>> (width-8)) ^^^ h}
    end
    new_crc = crc ^^^ Enum.at(table, index &&& 0xff)
    calc(params, new_crc, t)
  end

  defp calc(%Crc{width: width, ref_in: ref_in, ref_out: ref_out, xor_out: xor_out, bits_mask: bits_mask}, crc, <<>>) do
    (reflect(crc, width, ref_in !== ref_out) ^^^ xor_out) &&& bits_mask
  end
end
 
