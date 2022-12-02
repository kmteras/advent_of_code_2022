defmodule Day02P2 do

  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp score(list) do
    [o, m] = list
    |> String.split(" ")

    case m do
      "X" -> case o do
        "A" -> 0 + 3
        "B" -> 0 + 1
        "C" -> 0 + 2
      end
      "Y" -> case o do
       "A" -> 3 + 1
       "B" -> 3 + 2
       "C" -> 3 + 3
      end
      "Z" -> case o do
       "A" -> 6 + 2
       "B" -> 6 + 3
       "C" -> 6 + 1
     end
    end
  end
end
