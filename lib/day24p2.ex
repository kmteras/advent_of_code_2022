defmodule Day24P2 do
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

    initial_position = find_initial_position(grid)
    end_position = find_end_position(grid)

    IO.inspect(end_position)

    {to_end, grid} = move(grid, MapSet.new([initial_position]), end_position)
    {to_start, grid} = move(grid, MapSet.new([end_position]), initial_position)
    {to_end2, _} = move(grid, MapSet.new([initial_position]), end_position)
    to_end + to_start + to_end2
  end

  defp move(grid, positions, end_position, day \\ 0, visited \\ MapSet.new()) do
    if MapSet.member?(positions, end_position) do
      {day, grid}
    else
      blizzards = Enum.filter(grid, fn {_, value} -> is_list(value) && Enum.count(value) > 0 end)

#      draw_grid(grid)

#      IO.inspect(blizzards)
#      IO.inspect(positions)
#      IO.inspect(end_position)

      width_height = width_height(grid)

      # Remove all blizzards
      grid = for {position, values} <- grid, reduce: Map.new() do
        grid ->
          cond do
            values == "#" -> Map.put(grid, position, values)
            is_list(values) -> Map.put(grid, position, [])
          end
      end

      grid = for {{x, y} = position, values} <- blizzards, reduce: grid do
        grid ->
          for value <- values, reduce: grid do
            grid ->
              # TODO: handle wraparound
              new_position = case value do
                ">" -> try_move_or_wrap(grid, {x + 1, y}, width_height)
                "<" -> try_move_or_wrap(grid, {x - 1, y}, width_height)
                "v" -> try_move_or_wrap(grid, {x, y + 1}, width_height)
                "^" -> try_move_or_wrap(grid, {x, y - 1}, width_height)
              end

              # Add new element
              Map.update!(grid, new_position, fn list? ->
                cond do
                  is_list(list?) -> [value | list?]
                  true -> [list?]
                end
              end)
          end
      end

      new_blizzards = Enum.filter(grid, fn {_, value} -> is_list(value) && Enum.count(value) > 0 end)

      new_positions = for {x, y} <- positions, reduce: MapSet.new() do
        positions ->
          for {dx, dy} <- [{1, 0}, {0, 1}, {-1, 0}, {0, -1}, {0, 0}], reduce: positions do
            positions ->
              move_pos = Map.get(grid, {x + dx, y + dy})
              if is_list(move_pos) && Enum.count(move_pos) == 0 do
                MapSet.put(positions, {x + dx, y + dy})
              else
                positions
              end
          end
      end

      move(grid, new_positions, end_position, day + 1)
    end
  end

  defp draw_grid(grid) do
    {width, height} = width_height(grid)

    for y <- Range.new(0, height - 1) do
      line_s = for x <- Range.new(0, width - 1), reduce: "" do
        str ->
          case Map.get(grid, {x, y}) do
            "#" -> str <> "#"
            [] -> str <> "."
            [elem] -> str <> elem
            _ -> str <> Integer.to_string(Enum.count(Map.get(grid, {x, y})))
          end
      end

      IO.puts(line_s)
    end
  end

  defp try_move_or_wrap(grid, {x, y}, {width, height}) do
    cond do
      x == 0 -> {width - 2, y}
      y == 0 -> {x, height - 2}
      x == width - 1 -> {1, y}
      y == height - 1 -> {x, 1}
      true -> {x, y}
    end
  end

  def width_height(grid) do
    {{width, _}, _} = Enum.max_by(grid, fn {{x, y}, _} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{x, y}, _} -> y end)
    {width + 1, height + 1}
  end

  def find_initial_position(grid) do
    [{position, _}] = Enum.filter(grid, fn {{x, y}, value} -> value == [] && y == 0 end)
    position
  end

  def find_end_position(grid) do
    {_, height} = width_height(grid)
    [{position, _}] = Enum.filter(grid, fn {{x, y}, value} -> value == [] && y == height - 1 end)
    position
  end

  defp grid_to_map(lines) do
    for {line, y} <- Enum.with_index(lines), reduce: Map.new() do
      map ->
        line = String.graphemes(line)
        for {value, x} <- Enum.with_index(line), reduce: map do
          map ->
            cond do
              value == "#" -> Map.put(map, {x, y}, value)
              value == "." -> Map.put(map, {x, y}, [])
              true -> Map.update(map, {x, y}, [value], fn tile -> [value | tile] end)
            end
        end
    end
  end
end
