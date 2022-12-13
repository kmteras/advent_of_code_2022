defmodule Day13P1 do
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
      |> String.split("\n\n")
      |> Enum.map(&parse/1)
      |> Enum.map(&compare/1)
      |> Enum.with_index(1)
      |> Enum.filter(fn {truthy, index} -> truthy end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
  end

  defp parse(lines) do
    [left, right] = String.split(lines, "\n")

    {left, _} = Code.eval_string(left)
    {right, _} = Code.eval_string(right)

    {left, right}
  end

  defp compare({li, ri}) do
    cond do
      is_integer(li) && is_list(ri) ->
        compare({[li], ri})

      is_list(li) && is_integer(ri) ->
        compare({li, [ri]})

      is_number(li) && is_number(ri) && li < ri ->
        true

      is_number(li) && is_number(ri) && li == ri ->
        nil

      is_number(li) && is_number(ri) && li > ri ->
        false

      is_list(li) && is_list(ri) ->
        for i <- Range.new(0, max(Enum.count(li), Enum.count(ri)) - 1), reduce: nil do
          value -> compare_value(li, ri, i, value)
        end
    end
  end

  defp compare_value(_, _, _, true), do: true
  defp compare_value(_, _, _, false), do: false

  defp compare_value(li, ri, i, value) do
    cond do
      li == [] && ri == [] ->
        nil

      i >= Enum.count(li) ->
        true

      i >= Enum.count(ri) ->
        false

      true ->
        li = Enum.at(li, i)
        ri = Enum.at(ri, i)

        response = compare({li, ri})
        response
    end
  end
end
