defmodule BagParser do
  use Combine

  def parse(bag), do: Combine.parse(bag, parser())

  defp parser() do
    bag_kind()
    |> ignore(string(" contain "))
    |> either(
      string("no other bags"),
      sep_by1(
        sequence([integer(), ignore(space()), bag_kind()]),
        string(", ")
      )
    )
    |> ignore(string("."))
  end

  defp bag_kind() do
    map(
      sequence([word(), ignore(space()), word()]),
      fn w ->
        case w do
          [a, b] -> a <> " " <> b
          x -> x
        end
      end
    )
    |> ignore(sequence([space(), string("bag"), option(string("s"))]))
  end
end

defmodule Advent07 do
  def read_bags() do
    IO.stream(:stdio, :line)
    |> Enum.map(&BagParser.parse/1)
    |> Enum.reduce(%{}, fn el, acc ->
      Map.put(acc, hd(el), hd(tl(el)))
    end)
  end

  def num_holders(bag_map, kind \\ "shiny gold") do
    Enum.count(bag_map, fn {_k, spec} ->
      contains?(bag_map, spec, kind)
    end)
  end

  def num_holdees(bag_map, kind \\ "shiny gold") do
    spec = bag_map[kind]
    contents(bag_map, spec) - 1
  end

  defp contains?(bag_map, [[_count, k] | rest], kind) do
    k == kind or
      contains?(bag_map, bag_map[k], kind) or
      contains?(bag_map, rest, kind)
  end

  defp contains?(_, _, _), do: false

  defp contents(bag_map, [[count, k] | rest]) do
    count * contents(bag_map, bag_map[k]) + contents(bag_map, rest)
  end

  defp contents(_, _), do: 1
end

bag_map = Advent07.read_bags()

num_holders = Advent07.num_holders(bag_map)

IO.puts("number of shiny gold-compatible bags: #{num_holders}")

num_holdees = Advent07.num_holdees(bag_map)

IO.puts("number of bags in shiny gold: #{num_holdees}")
