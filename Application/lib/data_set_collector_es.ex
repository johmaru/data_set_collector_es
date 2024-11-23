defmodule DataSetCollectorEs do
  def create_settings do
    settings = %{
      "version" => "0.1.0",
      "data_path" => "data"
    }

    json_content = Jason.encode!(settings, pretty: true)
    File.write("settings.json", json_content)
  end

  def read_settings do
    case File.read("settings.json") do
      {:ok, content} ->
        Jason.decode!(content)

      {:error, _} ->
        IO.puts("Error reading settings.json")
        System.halt(1)
    end
  end

  def update_settings(new_data) do
    current_settings = read_settings()
    updated_settings = Map.merge(current_settings, new_data)
    json_content = Jason.encode!(updated_settings, pretty: true)
    File.write("settings.json", json_content)
  end

  def main(args) do
    IO.puts("Starting DataSetCollectorEs...")
    init()
  end

  def loading_task(task) do
    task
  end

  def init do
    loading_chars = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]

    task =
      Task.async(fn ->
        Enum.reduce_while(Stream.cycle(1..8), 0, fn i, acc ->
          IO.write("\r")
          loading_char = Enum.at(loading_chars, rem(i - 1, 8))
          IO.write("#{loading_char} Initializing data collection... ")
          Process.sleep(100)
          {:cont, acc + 1}
        end)
      end)

    if not File.dir?("logs") do
      File.mkdir!("logs")
    end

    if not File.exists?("settings.json") do
      create_settings()
    end

    settings = read_settings()
    data_path = settings["data_path"]

    if data_path && not File.dir?(data_path) do
      File.mkdir!(data_path)
    end

    Task.shutdown(task)
    IO.write("\rInitialized data collection! 🚀\n")
  end
end
