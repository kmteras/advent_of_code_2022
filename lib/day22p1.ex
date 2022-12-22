defmodule Day22P1 do
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
      |> String.trim_trailing()
      |> String.split("\n")

    {grid, directions} = Enum.split(data, -2)
    [_, directions] = directions

    grid_map = grid_to_map(grid)

    directions = split_directions(directions)

    starting_position = starting_position(grid_map)

    move(grid_map, directions, {1, 0}, starting_position)
  end

  @directions [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

  def move(_, [], direction, {x, y} = position) do
    score = (x + 1) * 4
    score = score + (y + 1) * 1000
    score = score + Enum.find_index(@directions, fn e -> e == direction end)

    score
  end

  def move(grid, [dir | directions], direction, position) do
#    IO.inspect({dir, direction, position})

    {position, direction} = case dir do
      dir when is_integer(dir) ->
        {move_in_dir(grid, direction, position, dir), direction}

      _ ->
        {position, rotate(direction, dir)}
    end

    move(grid, directions, direction, position)
  end

  def move_in_dir(grid, direction, position, 0) do
    position
  end

  def move_in_dir(grid, {dx, dy} = direction, {x, y} = position, moves_left) do
    new_position = new_position(grid, direction, position)
    tile_at_new_pos = Map.get(grid, new_position)
    cond do
      tile_at_new_pos == "#" ->
        position

      true ->
        move_in_dir(grid, direction, new_position, moves_left - 1)
    end
  end

  def new_position(grid, {dx, dy} = direction, {x, y} = position) do
    new_position = {x + dx, y + dy}
    tile_at_new_pos = Map.get(grid, new_position)

    if tile_at_new_pos == nil do
      find_wrap_around(grid, direction, position)
    else
      new_position
    end
  end

  def find_wrap_around(grid, direction, {px, py} = position) do
    case direction do
      {1, 0} ->
        # Find leftmost
        grid
        |> Map.keys()
        |> Enum.filter(fn {x, y} -> y == py end)
        |> Enum.min_by(fn {x, y} -> x end)

      {0, 1} ->
        # Find topmost
        grid
        |> Map.keys()
        |> Enum.filter(fn {x, y} -> x == px end)
        |> Enum.min_by(fn {x, y} -> y end)

      {-1, 0} ->
        # Find rightmost
        grid
        |> Map.keys()
        |> Enum.filter(fn {x, y} -> y == py end)
        |> Enum.max_by(fn {x, y} -> x end)

      {0, -1} ->
        # Find bottommost
        grid
        |> Map.keys()
        |> Enum.filter(fn {x, y} -> x == px end)
        |> Enum.max_by(fn {x, y} -> y end)
    end
  end

  def rotate(direction, command) do
    direction_index = Enum.find_index(@directions, fn e -> e == direction end)

    direction_index = if command == "L" do
      direction_index - 1
    else
      direction_index + 1
    end

    new_index = Integer.mod(direction_index, 4)
#    dbg
    Enum.at(@directions, new_index)
  end

  def starting_position(grid) do
    left_positions = Enum.filter(Map.keys(grid), fn {x, y} -> y == 0 end)
    Enum.min_by(left_positions, fn {x, y} -> x end)
  end

  defp grid_to_map(grid) do
    grid
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce(
         %{},
         fn {line, y}, map ->
           line
           |> Enum.with_index()
           |> Enum.reduce(
                %{},
                fn {tile, x}, map ->
                  if tile == "." or tile == "#" do
                    Map.put(map, {x, y}, tile)
                  else
                    map
                  end
                end
              )
           |> Map.merge(map)
         end
       )
  end

  defp move() do

  end

  defp split_directions(directions) do
    {_, dirs} = for graph <- String.graphemes(directions), reduce: {true, []} do
      {true, dirs} ->
        {false, dirs ++ [graph]}

      {false, dirs} ->
        if graph == "L" or graph == "R" do
          {true, dirs ++ [graph]}
        else
          {false, List.update_at(dirs, -1, fn v -> v <> graph end)}
        end
    end

    Enum.map(dirs,
      fn v ->
        case Integer.parse(v) do
          :error -> v
          {num, _} -> num
        end
      end)
  end
end
