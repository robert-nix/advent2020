defmodule Advent05 do
  def boarding_pass_to_id(l) do
    chars = String.codepoints(String.trim(l))

    binary =
      Enum.map(chars, &pos_to_binary/1)
      |> List.to_string()

    case Integer.parse(binary, 2) do
      {id, _} -> id
      :error -> 0
    end
  end

  defp pos_to_binary(c) do
    case c do
      "B" -> "1"
      "R" -> "1"
      _ -> "0"
    end
  end
end

ids =
  Enum.map(IO.stream(:stdio, :line), fn l ->
    Advent05.boarding_pass_to_id(l)
  end)

max_id = Enum.max(ids)
IO.puts("max id: #{max_id}")

my_id = Enum.sort(ids)
|> Enum.reduce_while(-1, fn b, a ->
  case b - a do
    2 -> {:halt, b - 1}
    _ -> {:cont, b}
  end
end)

IO.puts("my id: #{my_id}")
