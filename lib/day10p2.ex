defmodule Day10P2 do
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
    |> process()
    |> Enum.map(&Enum.join/1)
  end

  def process(
        instructions,
        info \\ {1, List.duplicate(List.duplicate(".", 40), 6), ["noop"], 0}
      )

  def process(code, {x, sum, last_ins, i}) do
    y = floor(i / 40)
    row = Enum.at(sum, y)

    sum = scan_pos(x, i, -1, sum, y, row)
    sum = scan_pos(x, i, 0, sum, y, row)
    sum = scan_pos(x, i, 1, sum, y, row)

    case last_ins do
      ["addx", amount] ->
        amount = to_integer(amount)
        process(code, {x + amount, sum, nil, i + 1})

      ["noop"] ->
        [ins | instructions] = get_next_instruction(code)
        process(instructions, {x, sum, ins, i + 1})

      nil ->
        [ins | instructions] = get_next_instruction(code)
        process(instructions, {x, sum, ins, i + 1})

      "stop" ->
        sum
    end
  end

  defp scan_pos(x, i, shift, sum, y, row) do
    if x == rem(i, 40) + shift do
      List.replace_at(sum, y, List.replace_at(row, rem(i, 40), "#"))
    else
      sum
    end
  end

  defp get_next_instruction(code) do
    if Enum.count(code) > 0 do
      code
    else
      ["stop"]
    end
  end
end
