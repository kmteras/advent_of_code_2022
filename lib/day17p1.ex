defmodule Day17P1 do
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

  defp tick(tick, data, rocks \\ 0, pos_info \\ {{2, 3}, {0, 0}})

  defp tick(grid, _, rocks, _) when rocks >= 2022 do
#    for {x, y} <- grid do
#      IO.puts("#{x}\t#{y}")
#    end

    floor_height(grid) + 1
  end

  defp tick(grid, {data, i}, rocks, {position, shift}) do
    jet = Enum.at(data, rem(i, Enum.count(data)))

    rock = Enum.at(@shapes, rem(rocks, 5))

#    IO.inspect({position, shift, jet})

    shift = move_jet(grid, jet, rock, {position, shift})

    case move_down(grid, rock, {position, shift}) do
      {:ok, shift} ->
        tick(grid, {data, i + 1}, rocks, {position, shift})

      {:error} ->
        grid = place_rock(grid, rock, {position, shift})
        y = floor_height(grid) + 1

#        dbg
        tick(grid, {data, i + 1}, rocks + 1, {{2, y + 3}, {0, 0}})
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
