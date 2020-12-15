defmodule Advent01 do
  # find two ints in a list that sum to sum
  def find(sum, asc) do
    if length(asc) < 2 do
      "Not found"
    else
      a = Enum.fetch!(asc, 0)
      b = Enum.fetch!(asc, -1)

      case a + b do
        v when v == sum -> {a, b}
        v when v < sum -> find(sum, tl(asc))
        v when v > sum -> find(sum, Enum.slice(asc, 0, length(asc) - 1))
        _ -> "Not found"
      end
    end
  end

  # find three ints in a list that sum to sum
  def find_three(sum, asc) do
    if length(asc) < 3 do
      "Not found"
    else
      a = Enum.fetch!(asc, 0)
      b = Enum.fetch!(asc, 1)
      c = Enum.fetch!(asc, -1)

      case a + b + c do
        v when v == sum ->
          {a, b, c}

        v when v < sum ->
          # (i think) only the ascending side of the 'triangle' needs to be tested,
          # that's why this recursion only happens when we go up the list
          case find(sum - a, tl(asc)) do
            {b, c} -> {a, b, c}
            "Not found" -> find_three(sum, tl(asc))
          end

        v when v > sum ->
          find_three(sum, Enum.slice(asc, 0, length(asc) - 1))

        _ ->
          "Not found"
      end
    end
  end
end

entries =
  Enum.sort(
    Enum.map(IO.binstream(:stdio, :line), fn l ->
      {i, _} = Integer.parse(l)
      i
    end)
  )

{a, b} = Advent01.find(2020, entries)
IO.puts(:stdio, "#{a} + #{b} = #{a + b}")
IO.puts(:stdio, "#{a} * #{b} = #{a * b}")

{a, b, c} = Advent01.find_three(2020, entries)
IO.puts(:stdio, "#{a} + #{b} + #{c} = #{a + b + c}")
IO.puts(:stdio, "#{a} * #{b} * #{c} = #{a * b * c}")
