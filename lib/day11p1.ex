defmodule Day11P1 do
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
    #    IEx.configure(inspect: [charlists: :as_lists])

    input =
      read!(filename)
      |> trim()
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))
      |> process_input()

    inspections = do_round(input, List.duplicate(0, Enum.count(elem(input, 0))))

    [m1, m2 | _] = Enum.sort(inspections, :desc)
    m1 * m2
  end

  def do_round({items, _, _}, inspections, 20) do
    inspections
  end

  def do_round({items, actions, conditions}, inspections, rounds \\ 0) do
    {items, inspections} =
      for {_, i} <- Enum.with_index(items), reduce: {items, inspections} do
        {items, inspections} ->
          m_items = Enum.at(items, i)

          operation = Enum.at(actions, i)
          condition = Enum.at(conditions, i)

          inspections =
            List.replace_at(inspections, i, Enum.at(inspections, i) + Enum.count(m_items))

          items =
            for item <- m_items, reduce: items do
              items ->
                worry =
                  case operation do
                    {:mul, :self} -> item * item
                    {:mul, amount} -> item * amount
                    {:add, amount} -> item + amount
                  end

                worry = floor(worry / 3)

                if rem(worry, elem(condition, 0)) == 0 do
                  new_list = Enum.at(items, elem(condition, 1)) ++ [worry]
                  List.replace_at(items, elem(condition, 1), new_list)
                else
                  new_list = Enum.at(items, elem(condition, 2)) ++ [worry]
                  List.replace_at(items, elem(condition, 2), new_list)
                end
            end

          items = List.replace_at(items, i, [])

          {items, inspections}
      end

    do_round({items, actions, conditions}, inspections, rounds + 1)
  end

  def process_input(monkeys) do
    for monkey <- monkeys, reduce: {[], [], []} do
      {items, actions, conditions} ->
        {item, action, condition} = process_monkey(monkey)
        {items ++ [item], actions ++ [action], conditions ++ [condition]}
    end
  end

  def process_monkey(monkey) do
    items =
      monkey
      |> at(1)
      |> String.replace(",", "")
      |> String.split()
      |> Enum.split(2)
      |> elem(1)
      |> Enum.map(&to_integer/1)

    "  Operation: new = old " <> operation = Enum.at(monkey, 2)

    operation = case String.split(operation, " ") do
      ["*", "old"] -> {:mul, :self}
      ["*", num] -> {:mul, to_integer(num)}
      ["+", num] -> {:add, to_integer(num)}
    end

    "  Test: divisible by " <> divisible = Enum.at(monkey, 3)
    "    If true: throw to monkey " <> when_true = Enum.at(monkey, 4)
    "    If false: throw to monkey " <> when_false = Enum.at(monkey, 5)

    {items, operation, {to_integer(divisible), to_integer(when_true), to_integer(when_false)}}
  end
end
