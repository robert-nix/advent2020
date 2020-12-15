defmodule Advent03 do
  def count_trees(trees, right, down) do
    count_trees(trees, 0, 0, right, down, length(hd(trees)))
  end

  def count_trees([row | rest], x, y, right, down, width) do
    if down <= 1 or Integer.mod(y, down) == 0 do
      count = (Enum.at(row, Integer.mod(x, width)) and 1) || 0
      count + count_trees(rest, x + right, y + 1, right, down, width)
    else
      count_trees(rest, x, y + 1, right, down, width)
    end
  end

  def count_trees(_, _, _, _, _, _), do: 0
end

trees =
  Enum.map(IO.stream(:stdio, :line), fn l ->
    Enum.map(String.codepoints(String.trim(l)), fn c -> c == "#" end)
  end)

total =
  Enum.reduce(
    Enum.map(
      [
        {1, 1},
        {3, 1},
        {5, 1},
        {7, 1},
        {1, 2}
      ],
      fn {right, down} ->
        count = Advent03.count_trees(trees, right, down)
        IO.puts("Right #{right}, down #{down}: #{count} trees")
        count
      end
    ),
    fn e, acc -> e * acc end
  )

IO.puts("Multiplied together: #{total}")
