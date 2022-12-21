defmodule Day21P1 do
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
      |> Enum.map(&parse_line/1)

    find_root(data)
  end

  defp find_root(data, values \\ Map.new())

  defp find_root([], values) do
    Map.get(values, "root")
  end

  defp find_root(data, values) do
    {values, data} = for {var, right} = line <- data, reduce: {values, []} do
      {values, data} ->
        case right do
          {:val, val} ->
            {Map.put(values, var, val), data}

          {op, {var1, var2}} ->
            v1 = Map.get(values, var1)
            v2 = Map.get(values, var2)

            if v1 != nil && v2 != nil do
              v = case op do
                :add -> v1 + v2
                :sub -> v1 - v2
                :mul -> v1 * v2
                :div -> v1 / v2
              end

              {Map.put(values, var, v), data}
            else
              {values, [line | data]}
            end
        end
    end

    find_root(data, values)
  end

  defp parse_line(line) do
    [var, value] = String.split(line, ": ")

    right = cond do
      String.contains?(value, "+") ->
        [var1, var2] = String.split(value, " + ")
        {:add, {var1, var2}}

      String.contains?(value, "-") ->
        [var1, var2] = String.split(value, " - ")
        {:sub, {var1, var2}}

      String.contains?(value, "*") ->
        [var1, var2] = String.split(value, " * ")
        {:mul, {var1, var2}}

      String.contains?(value, "/") ->
        [var1, var2] = String.split(value, " / ")
        {:div, {var1, var2}}

      true -> {:val, to_integer(value)}
    end

    {var, right}
  end
end
