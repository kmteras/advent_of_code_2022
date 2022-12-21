defmodule Day21P2 do
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
    before_data = data

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

    if Enum.count(data) == Enum.count(before_data) do
      find_humn_value(Map.new(data), values, "root")
    else
      find_root(data, values)
    end
  end

  defp find_humn_value(data, values, current_node, has_to_eq \\ nil) do
    {op, {var1, var2}} = Map.get(data, current_node)
    v1 = Map.get(values, var1)
    v2 = Map.get(values, var2)

    if v1 == nil do
      # Searching for v1

      case op do
        :eq -> find_humn_value(data, values, var1, v2)
        :add -> find_humn_value(data, values, var1, has_to_eq - v2)
        :mul -> find_humn_value(data, values, var1, has_to_eq / v2)
        :div -> find_humn_value(data, values, var1, has_to_eq * v2)
        :sub -> find_humn_value(data, values, var1, has_to_eq + v2)
        :me -> has_to_eq
      end
    else
      # Searching for v2

      case op do
        :eq -> find_humn_value(data, values, var2, v2)
        :add -> find_humn_value(data, values, var2, has_to_eq - v1)
        :mul -> find_humn_value(data, values, var2, has_to_eq / v1)
        :div -> find_humn_value(data, values, var2, has_to_eq * v1)
        :sub -> find_humn_value(data, values, var2, v1 - has_to_eq)
        :me -> has_to_eq
      end
    end
  end

  defp parse_line(line) do
    [var, value] = String.split(line, ": ")

    right = cond do
      var == "root" ->
        [var1, var2] = String.split(value, " + ")
        {:eq, {var1, var2}}

      var == "humn" ->
        {:me, {"random", "random"}}

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
