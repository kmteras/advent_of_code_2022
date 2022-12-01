defmodule Mix.Tasks.Day do
  use Mix.Task

  def run(args) do
    [day, example] = case args do
      [day] ->
        [day, false]

      [day, "-e"] ->
        [day, true]
    end

    [day_nr, _part] =
      day
      |> String.split("p")

    example_suffix = if example do
      "_example"
    else
      ""
    end

    module = Module.concat(["Day#{String.upcase(day)}"])
    IO.inspect(apply(module, :solve, ["input/day#{day_nr}#{example_suffix}.txt"]))
  end
end
