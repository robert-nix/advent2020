defmodule CodeParser do
  use Combine

  def parse(instruction) do
    case Combine.parse(instruction, parser()) do
      [op, delta] -> {op, delta}
      x -> x
    end
  end

  defp parser() do
    map(word(), &op_label/1)
    |> ignore(space())
    |> int_operand()
  end

  defp op_label("nop"), do: :nop
  defp op_label("acc"), do: :acc
  defp op_label("jmp"), do: :jmp
  defp op_label(op), do: {:error, "unknown op `#{op}`"}

  defp int_operand(parser) do
    map(
      parser,
      sequence([either(char(?+), char(?-)), integer()]),
      fn [sign, amount] ->
        case sign do
          "-" -> -amount
          "+" -> amount
        end
      end
    )
  end
end

defmodule VMState do
  defstruct ip: 0, acc: 0
end

defmodule CodeInterpreter do
  def step({op, delta}, %VMState{ip: ip, acc: acc}) do
    case op do
      :nop -> %VMState{ip: ip + 1, acc: acc}
      :acc -> %VMState{ip: ip + 1, acc: acc + delta}
      :jmp -> %VMState{ip: ip + delta, acc: acc}
    end
  end
end

defmodule Advent08 do
  def read_code() do
    IO.stream(:stdio, :line)
    |> Enum.map(&CodeParser.parse/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn el, acc ->
      {inst, ip} = el
      Map.put(acc, ip, inst)
    end)
  end

  def find_loop_acc(code, ips \\ %{}, state \\ %VMState{}) do
    case ips[state.ip] do
      1 ->
        state.acc

      _ ->
        find_loop_acc(
          code,
          Map.put(ips, state.ip, 1),
          CodeInterpreter.step(code[state.ip], state)
        )
    end
  end

  def find_fixed_acc(code, target_ip, ips \\ %{}, state \\ %VMState{}, changed \\ false)

  def find_fixed_acc(code, target_ip, ips, state, changed) do
    case ips[state.ip] do
      1 -> {:error, "loop detected"}
      _ -> find_fixed_acc_step(code, target_ip, ips, state, changed)
    end
  end

  def find_fixed_acc_step(_code, target_ip, _ips, state, _changed) when state.ip == target_ip,
    do: state.acc

  def find_fixed_acc_step(code, target_ip, ips, state, changed) do
    {op, delta} = code[state.ip]
    next_ips = Map.put(ips, state.ip, 1)

    found =
      find_fixed_acc(
        code,
        target_ip,
        next_ips,
        CodeInterpreter.step({op, delta}, state),
        changed
      )

    case found do
      {:error, _} when not changed and (op == :nop or op == :jmp) ->
        fixed_op = case op do
          :nop -> :jmp
          :jmp -> :nop
        end
        find_fixed_acc(
          code,
          target_ip,
          next_ips,
          CodeInterpreter.step({fixed_op, delta}, state),
          true
        )

      x ->
        x
    end
  end
end

code = Advent08.read_code()
acc = Advent08.find_loop_acc(code)
IO.puts("acc at loop event: #{acc}")

fixed_acc = Advent08.find_fixed_acc(code, Enum.count(code))
IO.puts("acc at end of fixed code: #{fixed_acc}")
