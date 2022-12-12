defmodule Day12P2 do
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

    candidates =
      Map.to_list(grid)
      # TODO: Remove hardcoded start x
      |> Enum.filter(fn {{x, y}, height} -> height == 97 && x == 0 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(fn start ->
        IO.inspect(start)
        traverse(grid, start, end_position, %{
          start => %{d: 0, parent: nil}
        })
      end)
      |> Enum.min()
  end

  defp traverse(grid, nil, end_pos, costs, visited) do
    1000000000000000000000
  end

  defp traverse(grid, {nx, ny} = position, {ex, ey} = end_pos, costs, visited \\ MapSet.new()) do
    if position == end_pos do
      find_path(costs, position, 0)
    else
      new_positions =
        for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: [] do
          next_list ->
            new_pos = {nx + dx, ny + dy}
            move_height = Map.get(grid, new_pos)
            current_height = Map.get(grid, position)

            if move_height && move_height - current_height <= 1 do
              [new_pos] ++ next_list
            else
              next_list
            end
        end

      costs =
        for {x, y} = pos <- new_positions, reduce: costs do
          costs ->
            n = Map.get(costs, position, %{d: 1000000000000000})

            if n.d + 1 < Map.get(costs, pos, %{d: 1000000000000000}).d do
              c = %{d: n.d + 1, parent: position}

              Map.put(costs, pos, c)
            else
              costs
            end
        end

      visited = MapSet.put(visited, position)

      {min_pos, _} = for {key, %{d: d}} <- Map.to_list(costs), reduce: {nil, 10000000000000} do
        {pos, distance} ->
          if not MapSet.member?(visited, key) && d < distance do
            {key, d}
          else
            {pos, distance}
          end
      end

      traverse(grid, min_pos, end_pos, costs, visited)
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
