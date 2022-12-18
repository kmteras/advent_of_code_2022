defmodule Day18P2 do
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

    {area, _, _} = connected_sides(data)

    area
  end

  @sides [{1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, {0, -1, 0}, {0, 0, 1}, {0, 0, -1}]

  defp connected_sides(cubes) do
    for {x, y, z} <- cubes, reduce: {0, MapSet.new(), MapSet.new()} do
      {count, outside_coords, inside_coords} ->
        for {sx, sy, sz} <- @sides, reduce: {count, outside_coords, inside_coords} do
          {count, outside_coords, inside_coords} ->
            pos = {x + sx, y + sy, z + sz}

            cond do
              MapSet.member?(cubes, pos) ->
                {count, outside_coords, inside_coords}

              MapSet.member?(inside_coords, pos) ->
                {count, outside_coords, inside_coords}

              MapSet.member?(outside_coords, pos) ->
                {count + 1, outside_coords, inside_coords}

              true ->
                {outside, coords} = dfs_outside(cubes, pos)

                if outside do
                  {count + 1, MapSet.union(outside_coords, coords), inside_coords}
                else
                  {count, outside_coords, MapSet.union(inside_coords, coords)}
                end
            end
        end
    end
  end

  defp dfs_outside(cubes, {x, y, z}, checked \\ MapSet.new()) do
    for {sx, sy, sz} <- @sides, reduce: {false, checked} do
      {reached_outside, visited_set} ->
        pos = {x + sx, y + sy, z + sz}

        cond do
          reached_outside ->
            {reached_outside, visited_set}

          MapSet.member?(checked, pos) ->
            {false, visited_set}

          # TODO: Define out of bounds programmatically
          x + sx >= 21 || x + sx < 0 ->
            {true, visited_set}

          y + sy >= 21 || y + sy < 0 ->
            {true, visited_set}

          z + sz >= 21 || z + sz < 0 ->
            {true, visited_set}

          MapSet.member?(cubes, pos) ->
            {false, visited_set}

          true ->
            checked = MapSet.put(visited_set, pos)
            dfs_outside(cubes, pos, checked)
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
