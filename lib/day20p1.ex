defmodule Day20P1 do
  use Agent

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
  #  import Map, only: [get: 2, get: 3, put: 3, has_key?: 2]
  import MapSet, only: [put: 2, member?: 2]

  def solve(filename) do
    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> Enum.map(&to_integer/1)
      |> Enum.with_index()

    size = Enum.count(data)

    move(data, data, size)
  end

  def move(order, [], size) do
    zero_index = Enum.find_index(order, fn {v, i} -> v == 0 end)

    i_1000th = Integer.mod(zero_index + 1000, Enum.count(order))
    i_2000th = Integer.mod(zero_index + 2000, Enum.count(order))
    i_3000th = Integer.mod(zero_index + 3000, Enum.count(order))

    {v_1000th, _} = Enum.at(order, i_1000th)
    {v_2000th, _} = Enum.at(order, i_2000th)
    {v_3000th, _} = Enum.at(order, i_3000th)

    v_1000th + v_2000th + v_3000th
  end

  def move(order, [{move, index} = element | rest], size) do
    index = Enum.find_index(order, fn {_, i} -> i == index end)
    order = List.delete_at(order, index)

    index = Integer.mod(index + move + Enum.count(order), Enum.count(order))

    order = List.insert_at(order, index, element)

    move(order, rest, size)
  end
end
