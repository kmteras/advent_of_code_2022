defmodule Day14P1 do
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
    read!(filename)
    |> trim()
    |> String.split("\n")
    |> Enum.map(&parse_path/1)
    |> fill_walls()
    |> simulate_sand()
  end

  def blocked?(grid, sand_grid, position) do
    MapSet.member?(grid, position) or MapSet.member?(sand_grid, position)
  end

  def simulate_sand(grid, sand_grid \\ MapSet.new(), sand_position \\ nil)

  def simulate_sand(grid, sand_grid, {sx, sy} = sand_position) when sand_position != nil do
    cond do
      sy == 1000 ->
        Enum.count(sand_grid)

      !blocked?(grid, sand_grid, {sx, sy + 1}) ->
        simulate_sand(grid, sand_grid, {sx, sy + 1})

      !blocked?(grid, sand_grid, {sx - 1, sy + 1}) ->
        simulate_sand(grid, sand_grid, {sx - 1, sy + 1})

      !blocked?(grid, sand_grid, {sx + 1, sy + 1}) ->
        simulate_sand(grid, sand_grid, {sx + 1, sy + 1})

      true ->
        simulate_sand(grid, MapSet.put(sand_grid, {sx, sy}), nil)
    end
  end

  def simulate_sand(grid, sand_grid, nil) do
    simulate_sand(grid, sand_grid, {500, 0})
  end

  def fill_walls(_, grid \\ MapSet.new())
  def fill_walls([], grid), do: grid

  def fill_walls([path | path_list], grid) do
    {_, grid} =
      for {cx, cy} = c <- path, reduce: {nil, grid} do
        {nil, grid} ->
          {c, grid}

        {{px, py}, grid} ->
          grid =
            if px == cx do
              for i <- Range.new(py, cy), reduce: grid do
                grid ->
                  MapSet.put(grid, {px, i})
              end
            else
              for i <- Range.new(px, cx), reduce: grid do
                grid ->
                  MapSet.put(grid, {i, py})
              end
            end

          {c, grid}
      end

    fill_walls(path_list, grid)
  end

  def parse_path(path_string) do
    path_string
    |> String.split(" -> ")
    |> Enum.map(fn coord ->
      [left, right] = String.split(coord, ",")
      {to_integer(left), to_integer(right)}
    end)
  end
end
