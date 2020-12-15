defmodule PassportParser do
  use Combine

  def parse(passports), do: Combine.parse(passports, parser())

  def valid?(passport) do
    case passport do
      %{
        :byr => byr,
        :iyr => iyr,
        :eyr => eyr,
        :hgt => hgt,
        :hcl => hcl,
        :ecl => ecl,
        :pid => pid
      } ->
        valid_year?(byr, 1920, 2002) and
          valid_year?(iyr, 2010, 2020) and
          valid_year?(eyr, 2020, 2030) and
          valid_height?(hgt) and
          valid_hair_color?(hcl) and
          valid_eye_color?(ecl) and
          valid_passport_id?(pid)

      _ ->
        false
    end
  end

  defp parser, do: sep_by1(passport(), newline()) |> eof()

  defp passport do
    choice([
      field("byr"),
      field("iyr"),
      field("eyr"),
      field("hgt"),
      field("hcl"),
      field("ecl"),
      field("pid"),
      field("cid")
    ])
    |> many()
    |> map(fn pairs ->
      Enum.reduce(pairs, %{}, fn it, m ->
        Map.put(m, String.to_atom(hd(it)), to_string(hd(tl(it))))
      end)
    end)
  end

  defp field(tag) do
    sequence([
      string(tag),
      ignore(char(":")),
      take_while(fn
        ?\s -> false
        ?\n -> false
        _ -> true
      end),
      ignore(either(spaces(), newline()))
    ])
  end

  def valid_year?(year, min, max) do
    String.length(year) == 4 and
      case Integer.parse(year) do
        {v, _} when v >= min and v <= max -> true
        _ -> false
      end
  end

  def valid_height?(str) do
    case Combine.parse(
           to_string(str),
           integer()
           |> either(string("cm"), string("in"))
         ) do
      [x, "cm"] when x >= 150 and x <= 193 -> true
      [x, "in"] when x >= 59 and x <= 76 -> true
      _ -> false
    end
  end

  def valid_hair_color?(str) do
    case Combine.parse(str, string("#") |> times(hex_digit(), 6)) do
      {:error, _} -> false
      _ -> true
    end
  end

  def valid_eye_color?(str) do
    Enum.any?(
      ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
      fn s -> s == str end
    )
  end

  def valid_passport_id?(str) do
    String.length(str) == 9 and
      case Combine.parse(str, integer()) do
        [x] when is_integer(x) -> true
        _ -> false
      end
  end
end

defmodule Advent04 do
end

[passports] = PassportParser.parse(IO.read(:stdio, :all))
#[passports] = PassportParser.parse("eyr:2024 pid:662406624 hcl:#cfa07d byr:1947 iyr:2015 ecl:amb hgt:150cm\n")

valid =
  Enum.count(passports, fn p ->
    case p do
      %{
        :byr => _,
        :iyr => _,
        :eyr => _,
        :hgt => _,
        :hcl => _,
        :ecl => _,
        :pid => _
      } ->
        true

      _ ->
        false
    end
  end)

IO.puts("valid: #{valid}")

validated =
  Enum.count(passports, fn p ->
    PassportParser.valid?(p)
  end)

IO.puts("validated: #{validated}")
