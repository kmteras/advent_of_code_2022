defmodule Day25P1 do
  use Agent

  import File, only: [read!: 1]

  import Enum,
    only: [
      chunk_every: 2,
      split: 2,
      reduce: 2,
      reduce: 3,
      at: 2,
      map: 2,
      with_index: 1,
      filter: 2
    ]

  import String, only: [trim: 1, to_integer: 1]
  #  import Map, only: [get: 2, get: 3, put: 3, has_key?: 2]
  import MapSet, only: [put: 2, member?: 2]

  def solve(filename) do
    sum =
      read!(filename)
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&parse_line/1)
      |> Enum.sum()
      |> IO.inspect()

    base_5_str = Integer.to_string(sum, 5)
    |> IO.inspect()
    |> String.graphemes()
    |> Enum.reverse()
    |> to_snafu()
  end

  defp to_snafu(_, carry \\ 0)

  defp to_snafu([], _), do: ""

  defp to_snafu([cur | base_5_int], carry) do
    cur = String.to_integer(cur)

    case cur + carry do
      0 -> to_snafu(base_5_int) <> "0"
      1 -> to_snafu(base_5_int) <> "1"
      2 -> to_snafu(base_5_int) <> "2"
      3 -> to_snafu(base_5_int, 1) <> "="
      4 -> to_snafu(base_5_int, 1) <> "-"
      5 -> to_snafu(base_5_int, 1) <> "0"
    end
  end

  defp parse_line(line) do
    for {c, i} <- Enum.with_index(Enum.reverse(String.graphemes(line))), reduce: 0 do
      sum ->
        case c do
          "2" -> sum + 2 * Integer.pow(5, i)
          "1" -> sum + 1 * Integer.pow(5, i)
          "0" -> sum + 0
          "-" -> sum + -1 * Integer.pow(5, i)
          "=" -> sum + -2 * Integer.pow(5, i)
        end
    end
  end
end
