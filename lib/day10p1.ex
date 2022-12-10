defmodule Day10P1 do
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
  end

  def process(
        instructions,
        info \\ {1, 0, ["noop"], 1}
      )

  def process(code, {x, sum, last_ins, i}) do
    sum =
      if rem(i - 20, 40) == 0 do
        sum + x * i
      else
        sum
      end

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

  def get_next_instruction(code) do
    if Enum.count(code) > 0 do
      code
    else
      ["stop"]
    end
  end
end
