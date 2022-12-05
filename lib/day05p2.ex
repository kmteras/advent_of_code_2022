defmodule Day05P2 do

  import File, only: [read!: 1]
  import Enum, only: [chunk_every: 2, split: 2, reduce: 2, reduce: 3, at: 2, map: 2, with_index: 1, filter: 2]
  import String, only: [trim: 1, to_integer: 1]
  import Map, only: [get: 2, get: 3, put: 3]

  def solve(filename) do
    [state, instructions] = read!(filename)
    |> String.trim_trailing()
    |> String.split("\n\n", trim: false)

    instructions =
      instructions
      |> trim()
      |> String.split("\n")
      |> map(&String.split(&1, " "))

    state = parse_state(state)

    move(state, instructions)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.join()
  end

  defp parse_state(state) do
    state =
      state
      |> String.split("\n", trim: false)

    {stacks, [stacks_amount]} = Enum.split(state, -1)

    stacks_amount = ceil((String.length(stacks_amount) + 1) / 4)

    stacks_list = List.duplicate([], stacks_amount)

    stacks
    |> Enum.reverse()
    |> Enum.reduce(stacks_list, &parse_stack/2)
  end

  defp parse_stack(layer, stacks_list) do
    stacks_list
    |> Enum.with_index()
    |> Enum.map(&parse_stack_layer_str(&1, layer))
  end

  defp parse_stack_layer_str({stack, index}, layer) do
    position = index * 4 + 1

    if String.length(layer) >= position && String.at(layer, position) != " " do
      [String.at(layer, position)] ++ stack
    else
       [] ++ stack
    end
  end

  defp move(state, []) do
    state
  end

  defp move(state, [ins | instructions]) do
    ins = parse_instruction(ins)

    state = state
    |> Enum.with_index()
    |> Enum.map(&do_move(&1, ins, state))

    move(state, instructions)
  end

  defp do_move({stack, i}, {count, from, to}, state) do
    case i do
      ^from ->
        {_, stack} = Enum.split(stack, count)
        stack

      ^to ->
        {m, _} = Enum.split(Enum.at(state, from), count)
        m ++ stack

      _ -> stack
    end
  end

  defp parse_instruction(ins) do
    {to_integer(Enum.at(ins, 1)), to_integer(Enum.at(ins, 3)) - 1, to_integer(Enum.at(ins, 5)) - 1}
  end
end
