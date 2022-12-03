defmodule Day03P2 do

  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.map(&mistake/1)
    |> Enum.sum()
  end

  defp mistake(items) do
    [i] = items
    |> Enum.map(fn list ->
      list
      |> String.graphemes()
      |> Enum.frequencies()
      |> Map.keys()
      |> MapSet.new()
    end)
    |> Enum.reduce(fn ms, acc ->
      MapSet.intersection(ms, acc)
    end)
    |> Enum.at(0)
    |> to_charlist()

    if i >= 97 do
     i - 96
    else
     i - 64 + 26
    end
  end
end
