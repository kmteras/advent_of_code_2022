defmodule Day23P1 do
  use Agent

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
    grid =
      read!(filename)
      |> String.trim_trailing()
      |> String.split("\n")
      |> grid_to_map()

    simulate(grid)
  end

  @positions [{1, 0}, {1, -1}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}]

  @proposals [
    {[{-1, -1}, {0, -1}, {1, -1}], {0, -1}},
    {[{-1, 1}, {0, 1}, {1, 1}], {0, 1}},
    {[{-1, -1}, {-1, 0}, {-1, 1}], {-1, 0}},
    {[{1, -1}, {1, 0}, {1, 1}], {1, 0}}
  ]

  defp simulate(grid, _, 10) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(grid, fn {x, y} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(grid, fn {x, y} -> y end)

    (max_x - min_x + 1) * (max_y - min_y + 1) - Enum.count(grid)
  end

  defp simulate(grid, proposals_order \\ @proposals, times \\ 0) do
    proposals =
      for {x, y} = position <- grid, reduce: Map.new() do
        proposals ->
          cond do
            empty_surroundings(grid, position) ->
              proposals

            true ->
              move = for {directions, move_dir} <- proposals_order, reduce: nil do
                nil ->
                  if Enum.any?(directions, fn {dx, dy} ->
                       MapSet.member?(grid, {dx + x, dy + y})
                     end) do
                    nil
                  else
                    move_dir
                  end

                anything ->
                  anything
              end

              if move do
                {dx, dy} = move
                Map.put(proposals, position, {x + dx, y + dy})
              else
                proposals
              end
          end
      end

    proposed_frequencies =
      proposals
      |> Map.values()
      |> Enum.frequencies()

    grid =
      for {from, into} <- proposals, reduce: grid do
        grid ->
          if Map.get(proposed_frequencies, into) > 1 do
            grid
          else
            grid
            |> MapSet.delete(from)
            |> MapSet.put(into)
          end
      end

    simulate(grid, Enum.slide(proposals_order, 0, -1), times + 1)
  end

  defp empty_surroundings(grid, {x, y} = position) do
    Enum.all?(@positions, fn {dx, dy} -> !MapSet.member?(grid, {dx + x, dy + y}) end)
  end

  defp grid_to_map(lines) do
    for {line, y} <- Enum.with_index(lines), reduce: MapSet.new() do
      map ->
        line = String.graphemes(line)
        for {value, x} <- Enum.with_index(line), reduce: map do
          map ->
            if value == "#" do
              MapSet.put(map, {x, y})
            else
              map
            end
        end
    end
  end
end
