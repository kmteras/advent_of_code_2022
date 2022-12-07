defmodule Day07P2 do
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
    {tree, _, _} =
      read!(filename)
      |> trim()
      |> String.split("\n")
      |> reduce({%{}, [], nil}, &parse_commands/2)

    {directory_sizes, _} = parse_directories(tree)

    used = Map.get(directory_sizes, "/")

    directory_sizes
    |> Map.to_list()
    |> Enum.filter(fn {_, ds} -> ds >= 30_000_000 - (70_000_000 - used) end)
    |> Enum.min_by(fn {_, ds} -> ds end)
  end

  defp parse_commands(command, acc) do
    if String.starts_with?(command, "$") do
      do_command(command, acc)
    else
      build_tree(command, acc)
    end
  end

  defp do_command(command, {tree, current_directory, last_command}) do
    [_, command | target] = String.split(command, " ")

    cond do
      command == "cd" && target == [".."] ->
        [last | rest] = current_directory
        {tree, rest, command}

      command == "cd" ->
        [target_name] = target
        tree = insert_into_tree(tree, current_directory, %{}, target_name)
        {tree, target ++ current_directory, command}

      command == "ls" ->
        {tree, current_directory, command}
    end
  end

  defp build_tree(command, {tree, current_directory, last_command}) do
    [size, file] = String.split(command, " ")

    if size == "dir" do
      tree = insert_into_tree(tree, Enum.reverse(current_directory), %{}, file)
      {tree, current_directory, last_command}
    else
      size = to_integer(size)
      tree = insert_into_tree(tree, Enum.reverse(current_directory), size, file)
      {tree, current_directory, last_command}
    end
  end

  defp insert_into_tree(tree, [] = current_directory, size, file) do
    Map.put(tree, file, size)
  end

  defp insert_into_tree(tree, [current | rest] = current_directory, size, file) do
    Map.replace_lazy(tree, current, fn element -> insert_into_tree(element, rest, size, file) end)
  end

  defp parse_directories(tree, _) when is_integer(tree) do
    {%{}, tree}
  end

  defp parse_directories(tree, name \\ "/") do
    {count, size} =
      tree
      |> Map.keys()
      |> Enum.reduce({%{}, 0}, fn key, {cc, ss} ->
        tree = Map.get(tree, key)
        {c, s} = parse_directories(tree, key)
        dbg

        {Map.merge(c, cc), s + ss}
      end)

    {Map.merge(count, %{name => size}), size}
  end
end
