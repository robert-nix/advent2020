defmodule Advent06 do
  def parse_responses(lines) do
    {l, m, c} =
      Enum.reduce(lines, {[], %{}, 0}, fn el, acc ->
        {l, m, c} = acc
        str = String.trim(el)

        if str == "" do
          {l ++ [{m, c}], %{}, 0}
        else
          {l, map_response(str, m), c + 1}
        end
      end)

    l ++ [{m, c}]
  end

  defp map_response(<<c::utf8, rest::binary>>, map) do
    map_response(
      rest,
      Map.merge(
        map,
        %{c => 1},
        fn _, v1, v2 -> v1 + v2 end
      )
    )
  end

  defp map_response(<<>>, m), do: m
end

responses =
  IO.stream(:stdio, :line)
  |> Advent06.parse_responses()

sum =
  Enum.map(responses, fn {m, _c} -> length(Map.keys(m)) end)
  |> Enum.sum()

IO.puts("sum of counts: #{sum}")

consensus_sum =
  Enum.map(
    responses,
    fn {m, c} ->
      Enum.count(m, fn {_k, v} -> v == c end)
    end
  )
  |> Enum.sum()

IO.puts("sum of consensus counts: #{consensus_sum}")
