defmodule Mix.Tasks.ExSort do
  use Mix.Task

  @shortdoc "Sorts aliases in the given files/patterns"

  @moduledoc """

  """

  @impl true
  def run(args) do
    args
    |> Task.async_stream(&sort_in_file(&1), ordered: false, timeout: 30000)
  end

  defp read_file(:stdin) do
    {IO.stream(:stdio, :line) |> Enum.to_list() |> IO.iodata_to_binary(), file: "stdin"}
  end

  defp read_file(file) do
    {File.read!(file), file: file}
  end

  defp sort_in_file(file) do
    {input, extra_opts} = read_file(file)
    output = IO.iodata_to_binary([Exsort.format_string!(input, extra_opts), ?\n])
    write_or_print(file, input, output)
  rescue
    exception ->
      {:exit, file, exception, __STACKTRACE__}
  end

  defp write_or_print(file, input, output) do
    cond do
      file == :stdin -> IO.write(output)
      input == output -> :ok
      true -> File.write!(file, output)
    end

    :ok
  end
end
