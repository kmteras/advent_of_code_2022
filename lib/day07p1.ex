defmodule Day07P1 do
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

    parse_directories(tree)
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

  defp parse_directories(tree) when is_integer(tree) do
    {0, tree}
  end

  defp parse_directories(tree) do
    {count, size} =
      tree
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn key, {cc, ss} ->
        tree = Map.get(tree, key)
        {c, s} = parse_directories(tree)
        dbg

        {c + cc, s + ss}
      end)

    if size <= 100_000 do
      {count + size, size}
    else
      {count, size}
    end
  end
end
