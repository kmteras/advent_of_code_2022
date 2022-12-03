defmodule Day03P1 do

  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&mistake/1)
    |> Enum.sum()
  end

  defp mistake(items) do
    {l, r} = items
    |> String.graphemes()
    |> Enum.split(floor(String.length(items) / 2))

    lm = l
    |> Enum.frequencies()
    |> Map.keys()
    |> MapSet.new()

   rm = r
    |> Enum.frequencies()
    |> Map.keys()
    |> MapSet.new()

    [i] = MapSet.intersection(lm, rm)
    |> MapSet.to_list()
    |> Enum.at(0)
    |> to_charlist()

    if i >= 97 do
     i - 96
    else
     i - 64 + 26
    end
  end
end
