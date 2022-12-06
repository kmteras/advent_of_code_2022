defmodule Day06P1 do

  import File, only: [read!: 1]
  import Enum, only: [chunk_every: 2, split: 2, reduce: 2, reduce: 3, at: 2, map: 2, with_index: 1, filter: 2]
  import String, only: [trim: 1, to_integer: 1]
  import Map, only: [get: 2, get: 3, put: 3]

  def solve(filename) do
    {_, _, ans} = read!(filename)
    |> trim()
    |> String.split("\n")
    |> Enum.at(0)
    |> String.graphemes()
    |> reduce({[], 0, nil}, &analyze/2)

    ans
  end

  def analyze(letter, {buffer, counter, ans} = acc) when not is_nil(ans) do
    acc
  end

  def analyze(letter, {buffer, counter, ans}) do
    if Enum.count(Map.keys(Enum.frequencies(buffer))) == 4 do
      {nil, nil, counter}
    else
      if Enum.count(buffer) == 4 do
        {_, buffer} = Enum.split(buffer, 1)
        {buffer ++ [letter], counter + 1, ans}
      else
        {buffer ++ [letter], counter + 1, ans}
      end
    end
  end
end
