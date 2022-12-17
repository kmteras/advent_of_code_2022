defmodule Day16P1 do
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
    data =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> reduce(%{}, &parse_line/2)

    best_path_state(data, [MapSet.new([%{valve: "AA", pressure: 0, releasing: 0, open: MapSet.new()}])])
  end

  def best_path_state(data, state) do
    if Enum.count(state) == 31 do
      state
      |> Enum.at(0)
      |> Enum.map(&(&1.pressure))
      |> Enum.sort()
      |> Enum.at(-1)
    else
      IO.inspect(Enum.count(state))

      latest_state = Enum.at(state, 0)

      latest_state =
        latest_state
        |> MapSet.to_list()
        |> Enum.sort(&(&1.pressure >= &2.pressure))
        |> Enum.take(100000)

#      IO.inspect(latest_state)

      new_states =
        for state <- latest_state, reduce: MapSet.new() do
          new_states ->
            valve_info = Map.get(data, state.valve)

            new_states = if !MapSet.member?(state.open, state.valve) do
              open_current = %{
                valve: state.valve,
                pressure: state.pressure + state.releasing,
                releasing: state.releasing + valve_info.p,
                open: MapSet.put(state.open, state.valve)
              }

              new_states = MapSet.put(new_states, open_current)
            else
              new_states
            end

            # Stop traversing when everything is open
            if Enum.count(Map.keys(data)) == MapSet.size(state.open) do
              new_states
            else
              for to <- valve_info.to, reduce: new_states do
                new_states ->
                  new_state = %{
                    valve: to,
                    pressure: state.pressure + state.releasing,
                    releasing: state.releasing,
                    open: state.open
                  }

                  MapSet.put(new_states, new_state)
              end
            end
        end

      best_path_state(data, [new_states] ++ state)
    end
  end

  def parse_line(line, flow_map) do
    splits =
      line
      |> String.replace("Valve ", "")
      |> String.replace("has flow rate=", "")
      |> String.replace("; tunnels lead to valves", "")
      |> String.replace("; tunnel leads to valve", "")
      |> String.replace(",", "")
      |> String.split()

    valve = Enum.at(splits, 0)
    pressure = to_integer(Enum.at(splits, 1))
    {_, to_valves} = Enum.split(splits, 2)
    Map.put(flow_map, valve, %{p: pressure, to: to_valves})
  end
end
