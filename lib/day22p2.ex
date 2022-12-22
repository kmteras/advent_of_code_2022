defmodule Day22P2 do
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
    IO.inspect(position)

    score = (x + 1) * 4
    score = score + (y + 1) * 1000
    score = score + Enum.find_index(@directions, fn e -> e == direction end)

    score
  end

  def move(grid, [dir | directions], direction, position) do
    #    IO.inspect({dir, direction, position})

    {position, direction} =
      case dir do
        dir when is_integer(dir) ->
          move_in_dir(grid, direction, position, dir)

        _ ->
          {position, rotate(direction, dir)}
      end

    move(grid, directions, direction, position)
  end

  def move_in_dir(grid, direction, position, 0) do
    {position, direction}
  end

  def move_in_dir(grid, {dx, dy} = direction, {x, y} = position, moves_left) do
    {new_position, new_direction} = new_position(grid, direction, position)
    tile_at_new_pos = Map.get(grid, new_position)

    cond do
      tile_at_new_pos == "#" ->
        {position, direction}

      true ->
        move_in_dir(grid, new_direction, new_position, moves_left - 1)
    end
  end

  def new_position(grid, {dx, dy} = direction, {x, y} = position) do
    new_position = {x + dx, y + dy}
    tile_at_new_pos = Map.get(grid, new_position)

    if tile_at_new_pos == nil do
#      IO.inspect({direction, position})
      find_wrap_around(grid, direction, position)
    else
      {new_position, direction}
    end
  end

  #  @grid_size 4
  @grid_size 50

  @position_to_char %{{1, 0} => ">", {-1, 0} => "<", {0, 1} => "V", {0, -1} => "^"}
  @grid_to_letter [{{1, 0}, "W"}, {{2, 0}, "O"}, {{1, 1}, "B"}, {{0, 2}, "R"}, {{1, 2}, "Y"}, {{0, 3}, "G"}]

  def find_wrap_around(grid, direction, {px, py} = position) do
    xg = floor(px / @grid_size)
    yg = floor(py / @grid_size)

    {_, letter} = Enum.find(@grid_to_letter, fn {gp, letter} -> gp == {xg, yg} end)
    char = Map.get(@position_to_char, direction)

    IO.inspect({letter, char})
    IO.inspect({position, direction})

    x_rem = rem(px, @grid_size)
    y_rem = rem(py, @grid_size)

    case {letter, char} do
      {"W", "^"} ->
        position_into("G", ">", direction, x_rem)

      {"G", "<"} ->
        position_into("W", "V", direction, y_rem)

      {"O", ">"} ->
        position_into("Y", "<", direction, @grid_size - y_rem - 1)

      {"Y", ">"} ->
        position_into("O", "<", direction, @grid_size - y_rem - 1)

      {"Y", "V"} ->
        position_into("G", "<", direction, x_rem)

      {"G", ">"} ->
        position_into("Y", "^", direction, y_rem)

      {"O", "V"} ->
        position_into("B", "<", direction, x_rem)

      {"B", ">"} ->
        position_into("O", "^", direction, y_rem)

      {"W", "<"} ->
        position_into("R", ">", direction, @grid_size - y_rem - 1)

      {"R", "<"} ->
        position_into("W", ">", direction, @grid_size - y_rem - 1)

      {"R", "^"} ->
        position_into("B", ">", direction, x_rem)

      {"G", "V"} ->
        position_into("O", "V", direction, x_rem)

      {"O", "^"} ->
        position_into("G", "^", direction, x_rem)

      {"B", "<"} ->
        position_into("R", "V", direction, y_rem)
    end
    |> IO.inspect()
  end

  def position_into(into_letter, into_side, direction, offset) do
    {{gx, gy}, _} = Enum.find(@grid_to_letter, fn {gp, letter} -> letter == into_letter end)

    case into_side do
      ">" ->
        {{gx * @grid_size, gy * @grid_size + offset}, {1, 0}}

      "V" ->
        {{gx * @grid_size + offset, gy * @grid_size}, {0, 1}}

      "<" ->
        {{gx * @grid_size + @grid_size - 1, gy * @grid_size + offset}, {-1, 0}}

      "^" ->
        {{gx * @grid_size + offset, gy * @grid_size + @grid_size - 1}, {0, -1}}
    end
  end

  def rotate(direction, command) do
    direction_index = Enum.find_index(@directions, fn e -> e == direction end)

    direction_index =
      if command == "L" do
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
    {_, dirs} =
      for graph <- String.graphemes(directions), reduce: {true, []} do
        {true, dirs} ->
          {false, dirs ++ [graph]}

        {false, dirs} ->
          if graph == "L" or graph == "R" do
            {true, dirs ++ [graph]}
          else
            {false, List.update_at(dirs, -1, fn v -> v <> graph end)}
          end
      end

    Enum.map(
      dirs,
      fn v ->
        case Integer.parse(v) do
          :error -> v
          {num, _} -> num
        end
      end
    )
  end
end
