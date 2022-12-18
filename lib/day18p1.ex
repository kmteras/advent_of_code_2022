defmodule Day18P1 do
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
    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> Enum.map(&parse_line/1)
      |> MapSet.new()

    connected_sides(data)
  end

  @sides [{1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, {0, -1, 0}, {0, 0, 1}, {0, 0, -1}]

  defp connected_sides(cubes) do
    for {x, y, z} <- cubes, reduce: 0 do
      count ->
        for {sx, sy, sz} <- @sides, reduce: count do
          count ->
            if MapSet.member?(cubes, {x + sx, y + sy, z + sz}) do
              count
            else
              count + 1
            end
        end
    end
  end

  defp parse_line(line) do
    [x, y, z] =
      line
      |> String.split(",")
      |> Enum.map(&to_integer/1)

    {x, y, z}
  end
end
