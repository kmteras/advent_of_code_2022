defmodule Day15P2 do
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
  import Map, only: [get: 2, get: 3, put: 3]

  def solve(filename) do
    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> map(&parse_sensor/1)

    ss =
      data
      |> map(&search_space(&1, 4000000))
#      |> map(&search_space(&1, 20))
      |> Enum.concat()
      |> MapSet.new()

    cannot_be_present(data, ss)
  end

  defp search_space({{sx, sy}, {bx, by}, d}, max) do
    for i <- Range.new(-d - 1, d + 1), reduce: [] do
      ss ->
        x = sx + i
        dd = (d + 1) - abs(i)

        if x >= 0 && x <= max do
          first = if sy + dd >= 0 && sy + dd <= max do
            [{x, sy + dd}]
          else
            []
          end

          second = if sy - dd >= 0 && sy - dd <= max do
            [{x, sy - dd}]
          else
            []
          end

          Enum.concat(first, second)
        else
          []
        end
        |> Enum.concat(ss)
    end
  end

  defp cannot_be_present(data, ss) do
    for {x, y} <- ss, reduce: nil do
      cannot_count ->
        if cannot_count do
          cannot_count
        else
          if !is_in_range(data, {x, y}) do
            x * 4_000_000 + y
          else
            cannot_count
          end
        end
    end
  end

  defp is_in_range([], _), do: false

  defp is_in_range([{{sx, sy}, _, d} | data], {x, y}) do
    if abs(sx - x) + abs(sy - y) <= d do
      true
    else
      is_in_range(data, {x, y})
    end
  end

  defp parse_sensor(sensor_line) do
    [sx, sy, bx, by] =
      sensor_line
      |> String.replace(":", "")
      |> String.replace(",", "")
      |> String.replace("Sensor at x=", "")
      |> String.replace("closest beacon is at x=", "")
      |> String.replace("y=", "")
      |> String.split(" ")
      |> map(&to_integer/1)

    {{sx, sy}, {bx, by}, abs(sx - bx) + abs(sy - by)}
  end
end
