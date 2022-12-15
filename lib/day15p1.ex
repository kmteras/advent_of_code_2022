defmodule Day15P1 do
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

    {min_x, max_x} =
      for {{sx, sy}, _, d} <- data, reduce: {100_000_000_000_000, -100_000_000_000_000} do
        {min_x, max_x} -> {min(min_x, sx - d), max(max_x, sx + d)}
      end

    cannot_be_present(data, {min_x, max_x}, 2000000)
  end

  defp cannot_be_present(data, {min_x, max_x}, y) do
    for x <- Range.new(min_x, max_x), reduce: 0 do
      cannot_count ->
        if is_in_range(data, {x, y}) && no_beacon_on_line(data, {x, y}) do
#          IO.inspect({x, y})
          cannot_count + 1
        else
          cannot_count
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

  defp no_beacon_on_line([], _), do: true

  defp no_beacon_on_line([{_, {bx, by}, _} | data], {x, y}) do
    if bx == x && by == y do
      false
    else
      no_beacon_on_line(data, {x, y})
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
