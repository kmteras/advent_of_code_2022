defmodule Day17P2 do
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

  @shapes ["-", "+", "L", "I", "S"]

  def solve(filename) do
    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> Enum.at(0)
      |> String.graphemes()

    # 1537175793194 - too high
    # 1537175793193 - too high

    tick(MapSet.new(), {data, 0})
  end

  defp floor_height(grid) do
    if Enum.count(grid) > 0 do
      grid
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()
    else
      0
    end
  end

  defp tick(grid, {data, i}, rocks \\ 0, {position, shift} \\ {{2, 3}, {0, 0}}, milestones \\ []) do
    floor_height = floor_height(grid)

    # Dont start checking until one cycle has passed to collect historic data and another has passed to collect milestones
    if i / Enum.count(data) > 3 && rem(rocks, 5) == 0 && {0, 0} == shift && Enum.count(milestones) > 0 do
      case is_pattern(grid, data, milestones) do
        {true, match_rocks, match_height} ->
          rocks_pattern = rocks - match_rocks
          height_pattern = floor_height - match_height

          [{last_rocks, last_height} | milestones] = milestones

          last_rocks = rocks
          last_height = floor_height

          rocks_left = 1000000000000 - last_rocks
          skip_height = floor(rocks_left / rocks_pattern) * height_pattern

          remainder = rem(rocks_left, rocks_pattern)

          IO.inspect({:pattern, remainder, skip_height + last_height})

          if remainder == 0 do
            skip_height + last_height + 1
          else
            tock(grid, {data, i}, rocks, {position, shift}, milestones)
          end

        {false, _, _} -> tock(grid, {data, i}, rocks, {position, shift}, milestones)
      end
    else
      tock(grid, {data, i}, rocks, {position, shift}, milestones)
    end
  end

  defp tock(grid, {data, i}, rocks \\ 0, {position, shift} \\ {{2, 3}, {0, 0}}, milestones \\ []) do
    floor_height = floor_height(grid)

    if rem(i, Enum.count(data)) == 0 do
      IO.inspect(i)
    end

    jet = Enum.at(data, rem(i, Enum.count(data)))
    rock = Enum.at(@shapes, rem(rocks, 5))

    milestones =
      # Don't add milestones before one cycle is complete
      if i / Enum.count(data) > 1 && rocks > 0 && rem(rocks, 5) == 0 && {0, 0} == shift do
        [{rocks, floor_height} | milestones]
      else
        milestones
      end

    shift = move_jet(grid, jet, rock, {position, shift})

    case move_down(grid, rock, {position, shift}) do
      {:ok, shift} ->
        tick(grid, {data, i + 1}, rocks, {position, shift}, milestones)

      {:error} ->
        grid = place_rock(grid, rock, {position, shift})
        y = floor_height(grid) + 1

        tick(grid, {data, i + 1}, rocks + 1, {{2, y + 3}, {0, 0}}, milestones)
    end
  end

  defp is_pattern(grid, data, milestones) do
    current_height = floor_height(grid)

    {_, milestones} = Enum.split(milestones, 10)

    # TODO: move grid down and check for any pattern

    for {rocks, milestone} <- milestones, reduce: {false, nil, nil} do
      {true, _, _} = ans ->
        ans

      {false, _, _} ->
        height_difference = current_height - milestone

        # -10 for buffer for unmoved pieces

        pattern_grid =
          MapSet.filter(grid, fn {x, y} ->
            y < current_height - 50 && y >= current_height - height_difference * 1
          end)
          |> Enum.map(fn {x, y} -> {x, y - height_difference} end)
          |> MapSet.new()

        match_grid =
          MapSet.filter(grid, fn {x, y} ->
            y < milestone - 50 && y >= milestone - height_difference * 1
          end)

        if height_difference == 2667 do
          IO.inspect("TOOYOO")
          dbg(current_height)
          dbg(MapSet.size(pattern_grid))
          dbg(MapSet.size(match_grid))

          dbg(MapSet.size(MapSet.symmetric_difference(pattern_grid, match_grid)))
        end

        if MapSet.equal?(pattern_grid, match_grid) do
          {true, rocks, milestone}
        else
          {false, nil, nil}
        end
    end
  end

  defp move_jet(grid, jet, rock, {{px, py}, {sx, sy} = shift}) do
    {nsx, nsy} =
      new_shift =
      case jet do
        ">" -> {sx, sy} = shift = {sx + 1, sy}
        "<" -> {sx, sy} = shift = {sx - 1, sy}
      end

    if check_collision(grid, rock, {px + nsx, py + nsy}) do
      shift
    else
      new_shift
    end
  end

  defp move_down(grid, rock, {{px, py}, {sx, sy}}) do
    {sx, sy} = shift = {sx, sy - 1}

    if check_collision(grid, rock, {px + sx, py + sy}) do
      {:error}
    else
      {:ok, shift}
    end
  end

  @offsets %{
    "-" => [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    "+" => [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}],
    "L" => [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    "I" => [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    "S" => [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  }

  defp check_collision(grid, rock, {x, y} = position) do
    case rock do
      "-" ->
        if x < 0 || x + 3 >= 7 || y < 0 do
          true
        else
          @offsets
          |> Map.get(rock)
          |> Enum.map(fn {ox, oy} -> member?(grid, {x + ox, y + oy}) end)
          |> Enum.any?()
        end

      "+" ->
        if x < 0 || x + 2 >= 7 || y < 0 do
          true
        else
          @offsets
          |> Map.get(rock)
          |> Enum.map(fn {ox, oy} -> member?(grid, {x + ox, y + oy}) end)
          |> Enum.any?()
        end

      "L" ->
        if x < 0 || x + 2 >= 7 || y < 0 do
          true
        else
          @offsets
          |> Map.get(rock)
          |> Enum.map(fn {ox, oy} -> member?(grid, {x + ox, y + oy}) end)
          |> Enum.any?()
        end

      "I" ->
        if x < 0 || x >= 7 || y < 0 do
          true
        else
          @offsets
          |> Map.get(rock)
          |> Enum.map(fn {ox, oy} -> member?(grid, {x + ox, y + oy}) end)
          |> Enum.any?()
        end

      "S" ->
        if x < 0 || x + 1 >= 7 || y < 0 do
          true
        else
          @offsets
          |> Map.get(rock)
          |> Enum.map(fn {ox, oy} -> member?(grid, {x + ox, y + oy}) end)
          |> Enum.any?()
        end
    end
  end

  defp place_rock(grid, rock, {{px, py}, {sx, sy}}) do
    {x, y} = {px + sx, py + sy}

    for {ox, oy} <- Map.get(@offsets, rock), reduce: grid do
      grid -> put(grid, {x + ox, y + oy})
    end
  end
end
