defmodule Day04P1 do

  import File, only: [read!: 1]
  import Enum, only: [chunk_every: 2, split: 2, reduce: 2, reduce: 3, at: 2, map: 2, with_index: 1, filter: 2]
  import String, only: [trim: 1, to_integer: 1]
  import Map, only: [get: 2, get: 3, put: 3]

  def solve(filename) do
    read!(filename)
    |> trim()
    |> String.split("\n")
    |> map(&section/1)
    |> Enum.sum()
  end

  defp section(sections) do
    [first, second] = String.split(sections, ",")

    [ff, ft] =
      first
      |> String.split("-")
      |> map(&to_integer/1)

    [sf, st] =
      second
      |> String.split("-")
      |> map(&to_integer/1)

    fms = MapSet.new(Range.new(ff, ft))
    sms = MapSet.new(Range.new(sf, st))

    inter = MapSet.intersection(fms, sms)

    if MapSet.equal?(fms, inter) do
      1
    else
      if MapSet.equal?(sms, inter) do
        1
      else
      0
      end
    end
  end
end
