defmodule Password do
  defstruct min: 0, max: 1, letter: "a", value: "hunter2"

  def parse(str) do
    {min, str} = Integer.parse(str)
    str = String.trim_leading(str, "-")
    {max, str} = Integer.parse(str)
    str = String.trim_leading(str)
    [letter, password] = String.split(str, ": ")

    %Password{
      min: min,
      max: max,
      letter: letter,
      value: String.trim(password)
    }
  end
end

defimpl String.Chars, for: Password do
  def to_string(p), do: "#{p.min}-#{p.max} #{p.letter}: #{p.value}"
end

defmodule Advent02 do
  def count_valid_passwords(entries) do
    Enum.count(entries, fn p ->
      freq = Enum.frequencies(String.codepoints(p.value))
      count = freq[p.letter] || 0
      count >= p.min and count <= p.max
    end)
  end

  def count_actual_valid_passwords(entries) do
    Enum.count(entries, fn p ->
      Enum.count([p.min, p.max], fn i ->
        String.at(p.value, i - 1) == p.letter
      end) == 1
    end)
  end
end

entries =
  Enum.map(IO.stream(:stdio, :line), fn l ->
    Password.parse(l)
  end)

IO.puts(Advent02.count_valid_passwords(entries))
IO.puts(Advent02.count_actual_valid_passwords(entries))
