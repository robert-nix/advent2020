defmodule XMASState do
  defstruct set: :ordsets.new(), idx: 0
end

defmodule XMAS do
  def update(state \\ %XMASState{}, n)

  def update(%XMASState{set: set, idx: idx}, n) when idx < 25 do
    %XMASState{set: :ordsets.add_element({n, idx}, set), idx: idx + 1}
  end

  def update(%XMASState{set: set, idx: idx}, n) do
    nums = :ordsets.to_list(set)

    case two_sum?(nums, n) do
      true -> next_state(set, idx, n)
      false -> {:error, n}
    end
  end

  defp next_state(set, idx, n) do
    set = :ordsets.filter(fn {_n, i} -> i > idx - 25 end, set)
    set = :ordsets.add_element({n, idx}, set)
    %XMASState{set: set, idx: idx + 1}
  end

  defp two_sum?(nums, n) do
    two_sum_impl?(nums, Enum.reverse(nums), n)
  end

  defp two_sum_impl?([a | _asc_rest], [d | _desc_rest], _n) when a == d, do: false

  defp two_sum_impl?([{a, _ai} | asc_rest] = asc, [{d, _di} | desc_rest] = desc, n) do
    case a + d do
      x when x == n -> true
      x when x < n -> two_sum_impl?(asc_rest, desc, n)
      x when x > n -> two_sum_impl?(asc, desc_rest, n)
    end
  end
end

defmodule Advent09 do
  def read_data() do
    IO.stream(:stdio, :line)
    |> Enum.map(fn l ->
      {n, _} = Integer.parse(l)
      n
    end)
  end

  def find_invalid_number(data) do
    Enum.reduce_while(data, %XMASState{}, fn n, state ->
      case XMAS.update(state, n) do
        {:error, n} -> {:halt, n}
        x -> {:cont, x}
      end
    end)
  end

  def find_weakness([_ | rest] = data, target) do
    {sum, list} =
      Enum.reduce_while(
        data,
        {0, []},
        fn el, {sum, l} ->
          next_sum = el + sum
          next = {next_sum, [el] ++ l}
          if next_sum >= target, do: {:halt, next}, else: {:cont, next}
        end
      )

    if sum == target do
      Enum.min(list) + Enum.max(list)
    else
      find_weakness(rest, target)
    end
  end
end

data = Advent09.read_data()
invalid_number = Advent09.find_invalid_number(data)
IO.puts("invalid number: #{invalid_number}")

weakness = Advent09.find_weakness(data, invalid_number)
IO.puts("weakness: #{weakness}")
