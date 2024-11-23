defmodule LogManage do
  def log(msg, level) do
    time = DataSetCollectorEs.get_instance_time()

    caller =
      Process.info(self(), :current_stacktrace)
      |> elem(1)
      |> Enum.at(1)

    {mod, fun, arity, location} = caller
    file = location[:file]
    line = location[:line]

    if not File.exists?("logs/#{time}.log") do
      IO.puts("Warning : Log file not found for #{time}.")
    end

    get_time =
      DateTime.utc_now()
      |> Calendar.strftime("%Y-%m-%d %H:%M:%S")

    File.write("logs/#{time}.log", "[#{get_time}] [#{level}] #{file}:#{line} : #{msg}\n", [
      :append
    ])
  end
end
