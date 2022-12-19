defmodule Day19P1 do
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
    options = [
      :set,
      :public,
      :named_table
    ]

    :ets.new(:memory, options)

    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> Enum.map(&parse_line/1)
      |> Task.async_stream(&geodes/1, timeout: :infinity)
      |> Enum.map(fn {:ok, geodes} -> geodes end)
      |> IO.inspect(charlists: :as_lists)
      |> Enum.with_index(1)
      |> Enum.map(fn {v, i} -> v * i end)
      |> Enum.sum()
  end

  defp geodes(cost, robots \\ [1, 0, 0, 0], resources \\ [0, 0, 0, 0], day \\ 0, cache \\ nil)

  defp geodes(_, _, resources, 24, _) do
    Enum.at(resources, 3)
  end

  defp geodes(
         [ore_ore, clay_ore, {obs_ore, obs_clay}, {geode_ore, geode_obs}] = costs,
         [ore_r, clay_r, obs_r, geode_r] = robots,
         [ore, clay, obs, geode] = resources,
         day,
         cache
       ) do
    cache = if cache do
      cache
    else
      :ets.new(:memory, [:set, :public])
    end

    cached_value = :ets.lookup(cache, {costs, robots, resources, day})

    if cached_value != [] do
      [{_, cache}] = cached_value
      cache
    else
      # List of new robots combinations
      new_robots_combination = MapSet.new()

      new_robots_combination =
        if (ore >= geode_ore || ore == :inf) && obs >= geode_obs do
          new_resources =
            if ore == :inf do
              [:inf, clay, obs - geode_obs, geode]
            else
              [ore - geode_ore, clay, obs - geode_obs, geode]
            end

          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 3, &(&1 + 1)), new_resources}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if (ore >= obs_ore || ore == :inf) && clay >= obs_clay && obs_r < geode_obs do
          new_resources =
            if ore == :inf do
              [:inf, clay - obs_clay, obs, geode]
            else
              [ore - obs_ore, clay - obs_clay, obs, geode]
            end

          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 2, &(&1 + 1)), new_resources}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if (ore >= clay_ore || ore == :inf) && clay_r < obs_clay do
          new_resources =
            if ore == :inf do
              [:inf, clay, obs, geode]
            else
              [ore - clay_ore, clay, obs, geode]
            end

          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 1, &(&1 + 1)), new_resources}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if (ore >= ore_ore || ore == :inf) &&
             (clay_ore > ore_r || obs_ore > ore_r || geode_ore > ore_r) do
          new_resources =
            if ore == :inf do
              [:inf, clay, obs, geode]
            else
              [ore - ore_ore, clay, obs, geode]
            end

          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 0, &(&1 + 1)), new_resources}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if MapSet.size(new_robots_combination) == 0 || ore_ore > ore_r do
          MapSet.put(new_robots_combination, {robots, robots, resources})
        else
          new_robots_combination
        end

      new_moves = MapSet.new()

      new_moves =
        for {robots, new_robots, resources} <- new_robots_combination, reduce: new_moves do
          new_moves ->
            new_resources =
              for {resource, index} <- Enum.with_index(resources) do
                cond do
                  resource == :inf -> :inf
                  index == 0 && Enum.at(robots, index) >= max_ore_cost(costs) -> :inf
                  true -> resource + Enum.at(robots, index)
                end
              end

            MapSet.put(new_moves, {costs, new_robots, new_resources})
        end

      geodes =
        for {costs, new_robots, new_resources} <- new_moves, reduce: 0 do
          geodes -> max(geodes, geodes(costs, new_robots, new_resources, day + 1, cache))
        end

      :ets.insert(cache, {{costs, robots, resources, day}, geodes})

      geodes
    end
  end

  defp max_ore_cost([ore_ore, clay_ore, {obs_ore, _}, {geode_ore, _}]) do
    Enum.max([ore_ore, clay_ore, obs_ore, geode_ore])
  end

  defp parse_line(line) do
    parts = String.split(line)

    ore_ore = to_integer(Enum.at(parts, 6))
    clay_ore = to_integer(Enum.at(parts, 12))
    obs_ore = to_integer(Enum.at(parts, 18))
    obs_clay = to_integer(Enum.at(parts, 21))
    geode_ore = to_integer(Enum.at(parts, 27))
    geode_obs = to_integer(Enum.at(parts, 30))

    [ore_ore, clay_ore, {obs_ore, obs_clay}, {geode_ore, geode_obs}]
  end
end
