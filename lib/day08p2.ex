defmodule Day08P2 do
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
    grid =
      read!(filename)
      |> trim()
      |> String.split("\n")

    grid_map = grid_to_map(grid)

    x_width = String.length(Enum.at(grid, 0))
    y_height = Enum.count(grid)

    # 2500 - too low
    best_viewing_distance(x_width, y_height, grid_map)
  end

  defp grid_to_map(grid) do
    grid
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {line, y}, map ->
        line
        |> Enum.with_index()
        |> Enum.reduce(
          %{},
          fn {risk, x}, map -> Map.put(map, {x, y}, String.to_integer(risk)) end
        )
        |> Map.merge(map)
      end
    )
  end

  defp tree_count(x_range, y, grid_map, position_height) do
    Enum.reduce(x_range, {-1, MapSet.new()}, fn x, {greatest, acc} ->
      tree_at_pos = Map.get(grid_map, {x, y})

      cond do
        tree_at_pos >= greatest && tree_at_pos >= position_height ->
          {100, MapSet.put(acc, {x, y})}

        tree_at_pos > greatest ->
          {greatest, MapSet.put(acc, {x, y})}

        true ->
          {greatest, acc}
      end
    end)
    |> elem(1)
  end

  defp tree_count_y(y_range, x, grid_map, position_height) do
    Enum.reduce(y_range, {-1, MapSet.new()}, fn y, {greatest, acc} ->
      tree_at_pos = Map.get(grid_map, {x, y})

      cond do
        tree_at_pos >= greatest && tree_at_pos >= position_height ->
          {100, MapSet.put(acc, {x, y})}

        tree_at_pos > greatest ->
          {greatest, MapSet.put(acc, {x, y})}

        true ->
          {greatest, acc}
      end
    end)
    |> elem(1)
  end

  defp best_viewing_distance(x_width, y_height, grid_map) do
    Enum.reduce(Map.keys(grid_map), 0, fn {x, y} = position, acc ->
      position_height = Map.get(grid_map, position)

      x_right =
        tree_count(
          Range.new(min(x + 1, x_width - 1), x_width - 1, 1),
          y,
          grid_map,
          position_height
        )

      x_left = tree_count(Range.new(max(0, x - 1), 0, -1), y, grid_map, position_height)

      y_down =
        tree_count_y(
          Range.new(min(y + 1, y_height - 1), y_height - 1, 1),
          x,
          grid_map,
          position_height
        )

      y_up = tree_count_y(Range.new(max(0, y - 1), 0, -1), x, grid_map, position_height)

      score = MapSet.size(x_right) * MapSet.size(x_left) * MapSet.size(y_down) * MapSet.size(y_up)

      if score > acc do
        score
      else
        acc
      end
    end)
  end
end
