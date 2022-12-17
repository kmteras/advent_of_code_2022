defmodule Day16P2 do
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

    # 2292

    best_path_state(data, [
      MapSet.new([%{valves: {"AA", "AA"}, pressure: 0, releasing: 0, open: MapSet.new()}])
    ])
  end

  def best_path_state(data, state) do
    if Enum.count(state) == 27 do
      IO.inspect(state)

      state
      |> Enum.at(0)
      |> Enum.map(& &1.pressure)
      |> Enum.sort()
      |> Enum.at(-1)
    else
      IO.inspect(Enum.count(state))

      latest_state = Enum.at(state, 0)

      latest_state =
        latest_state
        |> MapSet.to_list()
        |> Enum.sort(&(&1.pressure >= &2.pressure))
        |> Enum.take(5000)

      new_states =
        for state <- latest_state, reduce: MapSet.new() do
          new_states ->
            [{:open, :open}, {:open, :move}, {:move, :open}, {:move, :move}]
            {left_valve, right_valve} = state.valves

            left_valve_info = Map.get(data, left_valve)
            right_valve_info = Map.get(data, right_valve)

            # Stop traversing when everything is open
            if Enum.count(Map.keys(data)) == MapSet.size(state.open) do
              new_states
            else
              for left_to <- left_valve_info.to ++ [left_valve], reduce: new_states do
                new_states ->
                  for right_to <- right_valve_info.to ++ [right_valve], reduce: new_states do
                    new_states ->
                      cond do
                        left_valve == left_to && right_valve == right_to && left_valve_info.p != 0 && right_valve_info.p != 0 && left_valve != right_valve ->
                          if !MapSet.member?(state.open, left_valve) &&
                               !MapSet.member?(state.open, right_valve) do
                            open_current = %{
                              valves: {left_valve, right_valve},
                              pressure: state.pressure + state.releasing,
                              releasing: state.releasing + left_valve_info.p + right_valve_info.p,
                              open: MapSet.put(MapSet.put(state.open, right_valve), left_valve)
                            }

                            MapSet.put(new_states, open_current)
                          else
                            new_states
                          end

                        left_valve == left_to && left_valve_info.p != 0 ->
                          if !MapSet.member?(state.open, left_valve) do
                            open_current = %{
                              valves: {left_valve, right_to},
                              pressure: state.pressure + state.releasing,
                              releasing: state.releasing + left_valve_info.p,
                              open: MapSet.put(state.open, left_valve)
                            }

                            MapSet.put(new_states, open_current)
                          else
                            new_states
                          end

                        right_valve == right_to && right_valve_info.p != 0 ->
                          if !MapSet.member?(state.open, right_valve) do
                            open_current = %{
                              valves: {left_to, right_valve},
                              pressure: state.pressure + state.releasing,
                              releasing: state.releasing + right_valve_info.p,
                              open: MapSet.put(state.open, right_valve)
                            }

                            MapSet.put(new_states, open_current)
                          else
                            new_states
                          end

                        true ->
                          new_state = %{
                            valves: {left_to, right_to},
                            pressure: state.pressure + state.releasing,
                            releasing: state.releasing,
                            open: state.open
                          }

                          MapSet.put(new_states, new_state)
                      end
                  end
                  |> MapSet.union(new_states)
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
