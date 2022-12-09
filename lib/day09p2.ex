defmodule Day09P2 do
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
    |> Enum.map(&String.split(&1, " "))
    |> move()
    |> MapSet.size()
  end

  def move(
        instructions,
        moves \\ MapSet.new([{0, 0}]),
        position \\ {{0, 0}, List.duplicate({0, 0}, 9)}
      )

  def move([], moves, _) do
    moves
  end

  def move([[dir, a] | instructions], moves, {{hx, hy} = hp, tps}) do
    amount = to_integer(a)

    {x_list, y_list} =
      case dir do
        "R" -> {Range.new(hx + 1, hx + amount), [hy]}
        "L" -> {Range.new(hx - 1, hx - amount), [hy]}
        "U" -> {[hx], Range.new(hy + 1, hy + amount)}
        "D" -> {[hx], Range.new(hy - 1, hy - amount)}
      end

    {hp, tps, moves} =
      for x <- x_list, y <- y_list, reduce: {hp, tps, moves} do
        {{hx, hy}, tps, moves} ->
          hp = {x, y}
          tps = move_tails(hp, tps)
          {hp, tps, MapSet.put(moves, Enum.at(tps, -1))}
      end

    move(instructions, moves, {hp, tps})
  end

  defp move_tails(hp, tps) do
    {_, tps} =
      for tp <- tps, reduce: {hp, []} do
        {hp, tps} ->
          tp = move_tail(hp, tp)
          {tp, [tp] ++ tps}
      end

    Enum.reverse(tps)
  end

  defp move_tail({hx, hy}, {tx, ty} = tp) do
    {vx, vy} = v = {hx - tx, hy - ty}

    case v do
      {2, 2} -> {tx + 1, ty + 1}
      {2, -2} -> {tx + 1, ty - 1}
      {-2, 2} -> {tx - 1, ty + 1}
      {-2, -2} -> {tx - 1, ty - 1}
      {2, 1} -> {tx + 1, ty + 1}
      {2, 0} -> {tx + 1, ty}
      {2, -1} -> {tx + 1, ty - 1}
      {-2, 1} -> {tx - 1, ty + 1}
      {-2, 0} -> {tx - 1, ty}
      {-2, -1} -> {tx - 1, ty - 1}
      {1, 2} -> {tx + 1, ty + 1}
      {0, 2} -> {tx, ty + 1}
      {-1, 2} -> {tx - 1, ty + 1}
      {1, -2} -> {tx + 1, ty - 1}
      {0, -2} -> {tx, ty - 1}
      {-1, -2} -> {tx - 1, ty - 1}
      {1, 1} -> tp
      {1, 0} -> tp
      {1, -1} -> tp
      {-1, 1} -> tp
      {-1, 0} -> tp
      {-1, -1} -> tp
      {0, 1} -> tp
      {0, 0} -> tp
      {0, -1} -> tp
    end
  end
end
