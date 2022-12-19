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
    cache =
      if cache do
        cache
      else
        :ets.new(:memory, [:set, :public])
      end

    cached_value = :ets.lookup(cache, {robots, resources, day})

    if cached_value != [] do
      [{_, cache}] = cached_value
      cache
    else
      # List of new robots combinations
      new_robots_combination = MapSet.new()

      new_robots_combination = buy_robot(new_robots_combination, robots, resources, [geode_ore, 0, geode_obs], 3)

      new_robots_combination = if obs_r < geode_obs do
        buy_robot(new_robots_combination, robots, resources, [obs_ore, obs_clay, 0], 2)
      else
        new_robots_combination
      end

      new_robots_combination = if clay_r < obs_clay do
        buy_robot(new_robots_combination, robots, resources, [clay_ore, 0, 0], 1)
      else
        new_robots_combination
      end

      new_robots_combination = if ore_r < max_ore_cost(costs) do
        buy_robot(new_robots_combination, robots, resources, [ore_ore, 0, 0], 0)
      else
        new_robots_combination
      end

      new_robots_combination =
        if MapSet.size(new_robots_combination) == 0 || ore_ore > ore_r do
          MapSet.put(new_robots_combination, {robots, robots, resources})
        else
          new_robots_combination
        end

      new_moves =
        for {robots, new_robots, resources} <- new_robots_combination, reduce: MapSet.new() do
          new_moves ->
            new_resources =
              for {resource, index} <- Enum.with_index(resources) do
                cond do
                  resource == :inf -> :inf
                  index == 0 && Enum.at(robots, index) >= max_ore_cost(costs) -> :inf
                  index == 1 && Enum.at(robots, index) >= obs_clay -> :inf
                  index == 2 && Enum.at(robots, index) >= geode_obs -> :inf
                  true -> resource + Enum.at(robots, index)
                end
              end

            MapSet.put(new_moves, {costs, new_robots, new_resources})
        end

      geodes =
        for {costs, new_robots, new_resources} <- new_moves, reduce: 0 do
          geodes -> max(geodes, geodes(costs, new_robots, new_resources, day + 1, cache))
        end

      :ets.insert(cache, {{robots, resources, day}, geodes})

      if day == 0 do
        :ets.delete(cache)
      end

      geodes
    end
  end

  defp buy_robot(
         comb,
         [ore_r, clay_r, obs_r, geode_r] = robots,
         [ore, clay, obs, geode] = resources,
         [req_ore, req_clay, req_obs],
         robot_index
       ) do
      if (ore >= req_ore || ore == :inf) && (clay >= req_clay || clay == :inf) && (obs >= req_obs || obs == :inf) do
        ore = use_res(req_ore, ore)
        clay = use_res(req_clay, clay)
        obs = use_res(req_obs, obs)

        MapSet.put(
          comb,
          {robots, List.update_at(robots, robot_index, &(&1 + 1)), [ore, clay, obs, geode]}
        )
      else
        comb
      end
  end

  defp use_res(req_res, res) do
    if res == :inf do
      :inf
    else
      res - req_res
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
