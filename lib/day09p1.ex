defmodule Day09P1 do
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
    positions =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, " "))
      |> move()

    MapSet.size(positions)
  end

  def move(
        instructions,
        moves \\ MapSet.new([{0, 0}]),
        position \\ {{0, 0}, {0, 0}},
        last_move \\ nil
      )

  def move([], moves, _, _) do
    moves
  end

  def move([[dir, a] | instructions], moves, {{hx, hy} = hp, tp}, last_direction) do
    amount = to_integer(a)

    {hp, tp, moves} =
      case dir do
        "R" ->
          for x <- Range.new(hx + 1, hx + amount), reduce: {hp, tp, moves} do
            {{hx, hy}, tp, moves} ->
              hp = {x, hy}
              tp = move_tail(hp, tp)
              {hp, tp, MapSet.put(moves, tp)}
          end

        "L" ->
          for x <- Range.new(hx - 1, hx - amount), reduce: {hp, tp, moves} do
            {{hx, hy}, tp, moves} ->
              hp = {x, hy}
              tp = move_tail(hp, tp)

              {hp, tp, MapSet.put(moves, tp)}
          end

        "U" ->
          for y <- Range.new(hy + 1, hy + amount), reduce: {hp, tp, moves} do
            {{hx, hy}, tp, moves} ->
              hp = {hx, y}
              tp = move_tail(hp, tp)

              {hp, tp, MapSet.put(moves, tp)}
          end

        "D" ->
          for y <- Range.new(hy - 1, hy - amount), reduce: {hp, tp, moves} do
            {{hx, hy}, tp, moves} ->
              hp = {hx, y}
              tp = move_tail(hp, tp)
              {hp, tp, MapSet.put(moves, tp)}
          end
      end

    move(instructions, moves, {hp, tp}, dir)
  end

  defp move_tail({hx, hy}, {tx, ty} = tp) do
    v = {hx - tx, hy - ty}

    case v do
      {2, _} ->
        {hx - 1, hy}

      {_, 2} ->
        {hx, hy - 1}

      {-2, _} ->
        {hx + 1, hy}

      {_, -2} ->
        {hx, hy + 1}

      _ ->
        tp
    end
  end
end
