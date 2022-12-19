defmodule Day19P2 do
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
    Agent.start_link(fn -> %{} end, name: __MODULE__)

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
      |> Enum.take(3)
      |> Enum.map(&geodes/1)
      |> IO.inspect(charlists: :as_lists)
      |> Enum.product()
  end

  defp geodes(cost, robots \\ [1, 0, 0, 0], resources \\ [0, 0, 0, 0], day \\ 0)

  defp geodes(_, _, resources, 32) do
    Enum.at(resources, 3)
  end

  defp geodes(
         [ore_ore, clay_ore, {obs_ore, obs_clay}, {geode_ore, geode_obs}] = costs,
         [ore_r, clay_r, obs_r, geode_r] = robots,
         [ore, clay, obs, geode] = resources,
         day
       ) do
    if day == 0 do
      IO.inspect(costs)
    end

    cached_value = :ets.lookup(:memory, {costs, robots, day})

    cached_value = if cached_value == [] do
      :ets.lookup(:memory, {costs, robots, resources, day})
    else
      cached_value
    end
    #    cached_value = Agent.get(__MODULE__, &Map.get(&1, {costs, robots, resources, day}))

    if cached_value != [] do
      [{_, cache}] = cached_value
      cache
    else
      # List of new robots combinations
      new_robots_combination = MapSet.new()

      new_robots_combination =
        if ore >= geode_ore && obs >= geode_obs do
          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 3, &(&1 + 1)),
             [ore - geode_ore, clay, obs - geode_obs, geode]}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if ore >= obs_ore && clay >= obs_clay && obs_r < geode_obs do
          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 2, &(&1 + 1)),
             [ore - obs_ore, clay - obs_clay, obs, geode]}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if ore >= clay_ore && clay_r < obs_clay do
          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 1, &(&1 + 1)), [ore - clay_ore, clay, obs, geode]}
          )
        else
          new_robots_combination
        end

      new_robots_combination =
        if ore >= ore_ore &&
             (clay_ore > ore_r || obs_ore > ore_r || geode_ore > ore_r || ore_ore > ore_r) do
          MapSet.put(
            new_robots_combination,
            {robots, List.update_at(robots, 0, &(&1 + 1)), [ore - ore_ore, clay, obs, geode]}
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
                resource + Enum.at(robots, index)
              end

            MapSet.put(new_moves, {costs, new_robots, new_resources})
        end

      geodes =
        for {costs, new_robots, new_resources} <- new_moves, reduce: 0 do
          geodes -> max(geodes, geodes(costs, new_robots, new_resources, day + 1))
        end

      if day > 26 do
        :ets.insert(:memory, {{costs, robots, day}, geodes})
      else
        :ets.insert(:memory, {{costs, robots, resources, day}, geodes})
      end

      #      Agent.update(__MODULE__, &Map.put(&1, {costs, robots, resources, day}, geodes))

      geodes
    end
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
