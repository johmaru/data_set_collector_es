defmodule DataSetCollectorEs do
  @log_level {"INFO", "WARN", "ERROR"}

  def create_settings do
    settings = %{
      "version" => "0.1.0",
      "data_path" => "data"
    }

    json_content = Jason.encode!(settings, pretty: true)
    File.write("settings.json", json_content)
  end

  def set_instance_time do
    Application.put_env(:data_set_collector_es, :instance_time, get_time())
  end

  def get_instance_time do
    Application.get_env(:data_set_collector_es, :instance_time)
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
    IO.puts("DataSetCollectorEsを開始しました...")
    init()
    show_menu()
  end

  def show_menu do
    :io.setopts(:stdio, binary: true, echo: false)

    options = [
      "1. データセットを作成",
      "2. データセットをロード",
      "3. データセットの保存場所を変更",
      "4. 終了"
    ]

    Enum.each(options, &IO.puts/1)
    selection = IO.gets("番号を入力してください: ")
    handle_selection(String.trim(selection))
  end

  def handle_selection("1") do
    CreateDataSet.create_data_set()
  end

  def handle_selection("2") do
    IO.puts("読み込み中")
  end

  def handle_selection("3") do
    IO.puts("データパスを変更します")
    new_data_path = IO.gets("新しいデータパスを入力してください 例(c:/data): ")
    update_settings(%{"data_path" => String.trim(new_data_path)})
    IO.puts("データパスを変更しました")
    LogManage.log("Changed data path to #{new_data_path}", elem(@log_level, 0))
    IO.puts("\n\n")
    show_menu()
  end

  def handle_selection("4") do
    IO.puts("終了します")
    LogManage.log("Exiting DataSetCollectorEs", elem(@log_level, 0))
    System.halt(0)
  end

  def handle_selection(_) do
    IO.puts("無効な選択です")
    IO.puts("\n\n")
    show_menu()
  end

  def loading_task(task) do
    task
  end

  def get_time do
    now = DateTime.utc_now()
    "#{now.year}-#{pad_number(now.month)}-#{pad_number(now.day)}"
  end

  defp pad_number(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  def init do
    loading_chars = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]

    task =
      Task.async(fn ->
        Enum.reduce_while(Stream.cycle(1..8), 0, fn i, acc ->
          IO.write("\r")
          loading_char = Enum.at(loading_chars, rem(i - 1, 8))
          IO.write("#{loading_char} データコレクションを初期化中... ")
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

    set_instance_time()

    if not File.exists?("logs/#{get_instance_time()}.log") do
      File.write("logs/#{get_instance_time()}.log", "Initialized Log File\n\n")
    end

    Task.shutdown(task)
    IO.write("\rInitialized data collection! 🚀\n")
    LogManage.log("Initialized data collection", elem(@log_level, 0))
  end
end
