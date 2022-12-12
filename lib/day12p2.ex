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

          v = cond do
            key == end_position -> 122
            key == start_position -> 97
            true -> v
          end

          {key, v}
        end
      )

    costs = traverse(grid, end_position, %{
      end_position => %{d: 0, parent: nil}
    })

    candidates =
      Map.to_list(grid)
      |> Enum.filter(fn {{x, y}, height} -> height == 97 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&Map.get(costs, &1, %{d: 100000000}).d)
      |> Enum.min()
  end

  defp traverse(grid, nil, costs, visited) do
    costs
  end

  defp traverse(grid, {nx, ny} = position, costs, visited \\ MapSet.new()) do
    current_height = Map.get(grid, position)

    new_positions =
      for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: [] do
        next_list ->
          new_pos = {nx + dx, ny + dy}
          move_height = Map.get(grid, new_pos)

          if move_height && move_height - current_height >= -1 do
            [new_pos] ++ next_list
          else
            next_list
          end
      end

    n = Map.get(costs, position, %{d: 1000000000000000})

    costs =
      for {x, y} = pos <- new_positions, reduce: costs do
        costs ->
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

    traverse(grid, min_pos, costs, visited)
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
