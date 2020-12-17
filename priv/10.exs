defmodule Advent10 do
  def read_ratings() do
    IO.stream(:stdio, :line)
    |> Enum.map(fn l ->
      {n, _} = Integer.parse(l)
      n
    end)
  end

  def joltage_differences(ratings) do
    {d1, d2, d3, _} =
      Enum.reduce(
        Enum.sort(ratings),
        {0, 0, 0, 0},
        fn j, {d1, d2, d3, last} ->
          case j - last do
            1 -> {d1 + 1, d2, d3, j}
            2 -> {d1, d2 + 1, d3, j}
            3 -> {d1, d2, d3 + 1, j}
          end
        end
      )

    {d1, d2, d3 + 1}
  end

  def count_sum_sets(n) when n <= 1, do: 1

  def count_sum_sets(n) do
    # start at n 1's
    # for each i=0..n-2:
    #   attempt to collapse k[i], k[i+1] into their sum
    #   if this permutation is descending, then it is a novel permutation to be counted
    #     add the number of ways this sum can be written
    #     (i.e. nCk for n = number of places, k = 1 less than count of distinct summands)
    summands = Enum.map(1..n, fn _ -> 1 end)
    1 + sum_subset_permutations(summands)
  end

  def count_charger_permutations(ratings) do
    {deltas, _} =
      Enum.reduce(
        Enum.sort(ratings),
        {[3], 0},
        fn j, {l, last} ->
          {l ++ [j - last], j}
        end
      )

    Enum.reverse(deltas)
    |> Enum.reduce({1, 0}, fn delta, {p, ones} ->
      if delta == 1 do
        {p, ones + 1}
      else
        IO.puts("adding sets for #{ones} ones")
        {p * count_sum_sets(ones), 0}
      end
    end)
  end

  defp sum_subset_permutations(summands) when length(summands) == 1, do: 0

  defp sum_subset_permutations(summands) do
    n = length(summands)

    Enum.map(0..(n - 2), fn i ->
      {first, last} = Enum.split(summands, i)
      {two, last} = Enum.split(last, 2)
      midsum = Enum.sum(two)

      if midsum > 3 do
        0
      else
        collapsed = first ++ [midsum] ++ last

        case is_descending?(collapsed) do
          true -> count_sum_permutations(collapsed) + sum_subset_permutations(collapsed)
          false -> 0
        end
      end
    end)
    |> Enum.sum()
  end

  defp count_sum_permutations(summands) do
    n = length(summands)
    k = length(Enum.dedup(summands)) - 1
    choose(n, k)
  end

  def is_descending?([]), do: false
  def is_descending?([head | tail]), do: is_descending?(head, tail)
  defp is_descending?(el, [head | tail]), do: el >= head and is_descending?(head, tail)
  defp is_descending?(_el, []), do: true

  def choose(n, k) when k > 0, do: choose(n, k, 1, 1)
  def choose(_n, k) when k == 0, do: 1

  defp choose(n, k, i, num) do
    next = div(num * (n + 1 - i), i)

    if i == k do
      next
    else
      choose(n, k, i + 1, next)
    end
  end
end

ratings = Advent10.read_ratings()
{d1, d2, d3} = Advent10.joltage_differences(ratings)
IO.puts("d1 = #{d1}; d2 = #{d2}; d3 = #{d3}; d1 * d3 = #{d1 * d3}")

Enum.each(1..10, fn i ->
  sums = Advent10.count_sum_sets(i)
  IO.puts("count_sum_sets(#{i}) = #{sums}")
end)

permutations = Advent10.count_charger_permutations(ratings)
IO.puts("charger permutations: #{permutations}")
