defmodule Day08P1 do
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

    x_right = tree_count(Range.new(0, x_width - 1), Range.new(0, y_height - 1), grid_map)
    x_left = tree_count(Range.new(x_width - 1, 0), Range.new(0, y_height - 1), grid_map)
    y_down = tree_count_y(Range.new(0, y_height - 1), Range.new(0, x_width - 1), grid_map)
    y_up = tree_count_y(Range.new(y_height - 1, 0), Range.new(0, x_width - 1), grid_map)

    x_ms = MapSet.union(x_right, x_left)
    y_ms = MapSet.union(y_down, y_up)

#    border_ms = border_counts(grid_map, x_width, y_height)

    # 6640

    ms = MapSet.union(x_ms, y_ms)
#    |> dbg

    MapSet.size(ms)
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

  defp tree_count(x_range, y_range, grid_map) do
    Enum.reduce(y_range, MapSet.new(), fn y, y_acc ->
      {_, x_acc} =
        Enum.reduce(x_range, {-1, MapSet.new()}, fn x, {greatest, acc} ->
          tree_at_pos = Map.get(grid_map, {x, y})

          if tree_at_pos > greatest do
            {tree_at_pos, MapSet.put(acc, {x, y})}
          else
            {greatest, acc}
          end
        end)
      MapSet.union(y_acc, x_acc)
    end)
  end

  defp tree_count_y(y_range, x_range, grid_map) do
    Enum.reduce(x_range, MapSet.new(), fn x, x_acc ->
      {_, y_acc} =
        Enum.reduce(y_range, {-1, MapSet.new()}, fn y, {greatest, acc} ->
          tree_at_pos = Map.get(grid_map, {x, y})

          if tree_at_pos > greatest do
            {tree_at_pos, MapSet.put(acc, {x, y})}
          else
            {greatest, acc}
          end
        end)
      MapSet.union(y_acc, x_acc)
    end)
  end

  defp border_counts(grid_map, width, height) do
    y = Enum.reduce([0, width - 1], MapSet.new(), fn x, x_acc ->
      y_acc =
        Enum.reduce(Range.new(0, height - 1), MapSet.new(), fn y, acc ->
          MapSet.put(acc, {x, y})
        end)
      MapSet.union(y_acc, x_acc)
    end)

    x = Enum.reduce([0, height - 1], MapSet.new(), fn y, y_acc ->
      x_acc =
        Enum.reduce(Range.new(0, width - 1), MapSet.new(), fn x, acc ->
          MapSet.put(acc, {x, y})
        end)
      MapSet.union(y_acc, x_acc)
    end)

    MapSet.union(x, y)
  end
end
