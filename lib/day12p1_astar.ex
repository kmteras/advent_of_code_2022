defmodule Day12P1Astar do
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
      |> grid_to_map()

    start_position = start_position(Map.to_list(grid))
    end_position = end_position(Map.to_list(grid))

    grid =
      Map.new(
        for {key, value} <- Map.to_list(grid) do
          <<v::utf8>> = value

          v =
            if key == end_position do
              122
            else
              if key == start_position do
                97
              else
                v
              end
            end

          {key, v}
        end
      )

    traverse(grid, end_position, MapSet.new([start_position]), %{
      start_position => %{g: 0, h: 0, f: 0, parent: nil}
    })
  end

  defp traverse(grid, {ex, ey} = end_pos, open_set, costs, steps \\ 0) do
    {_, current_node} =
      for n <- open_set, reduce: {10_000_000, nil} do
        {f_cost, current_node} ->
          f = Map.get(costs, n).f

          if f < f_cost do
            {f, n}
          else
            {f_cost, current_node}
          end
      end

    open_set = MapSet.delete(open_set, current_node)
    {cx, cy} = current_node

    if current_node == end_pos do
      find_path(costs, current_node, 0)
    else
      new_positions =
        for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: [] do
          next_list ->
            new_pos = {cx + dx, cy + dy}
            move_height = Map.get(grid, new_pos)
            current_height = Map.get(grid, current_node)

            if move_height && move_height - current_height <= 1 do
              [new_pos] ++ next_list
            else
              next_list
            end
        end

      {open_set, costs} =
        for {x, y} = pos <- new_positions, reduce: {open_set, costs} do
          {open_set, costs} ->
            g = abs(cx - x) + abs(cy - y)

            if g < Map.get(costs, pos, %{g: 1000000000000000}).g do
              h = abs(cx - ex) + abs(cy - ey)
              c = %{g: g, f: g + h, h: h, parent: current_node}

              {MapSet.put(open_set, pos), Map.put(costs, pos, c)}
            else
              {open_set, costs}
            end
        end

      traverse(grid, end_pos, open_set, costs)
    end
  end

  defp find_path(costs, node, steps) do
    parent = Map.get(costs, node).parent

    if parent == nil do
      steps
    else
      find_path(costs, parent, steps + 1)
    end
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
          fn {risk, x}, map -> Map.put(map, {x, y}, risk) end
        )
        |> Map.merge(map)
      end
    )
  end

  defp start_position([{key, value} | grid]) do
    if value == "S" do
      key
    else
      start_position(grid)
    end
  end

  defp end_position([{key, value} | grid]) do
    if value == "E" do
      key
    else
      end_position(grid)
    end
  end
end
