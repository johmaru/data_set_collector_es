defmodule CreateDataSet do
  def loading_task(task) do
    task
  end

  def create_content do
    File.write("#{get_instance_path()}/content.json", "")
  end

  @qa_content_structure %{
    "entries" => [
      %{
        "question" => "",
        "answer" => "",
        "label" => "",
        "type" => ""
      }
    ]
  }

  def append_qa(question, answer, label) do
    new_entry = %{
      "question" => question,
      "answer" => answer,
      "label" => label,
      "type" => "#{get_instance_type()}"
    }

    current_content =
      case read_content() do
        {:ok, content} -> content
        {:error, _} -> %{"entries" => []}
      end

    update_content =
      Map.update(current_content, "entries", [new_entry], fn entries -> entries ++ [new_entry] end)

    json_content = Jason.encode!(update_content, pretty: true)
    File.write("#{get_instance_path()}/content.json", json_content)
  end

  def read_content do
    case File.read("#{get_instance_path()}/content.json") do
      {:ok, content} ->
        Jason.decode!(content)

      {:error, _} ->
        IO.puts("Error reading settings.json")
        System.halt(1)
    end
  end

  def update_content(new_data) do
    current_content = read_content()
    updated_content = Map.merge(current_content, new_data)
    json_content = Jason.encode!(updated_content, pretty: true)
    File.write("#{get_instance_path()}/settings.json", json_content)
  end

  def create_setting do
    setting = %{
      "data_set_name" => "#{get_instance_name()}",
      "type" => "#{get_instance_type()}"
    }

    json_content = Jason.encode!(setting, pretty: true)
    File.write("#{get_instance_path()}/settings.json", json_content)
  end

  def read_settings(name) do
    File.read!("#{name}/settings.json")
    |> Jason.decode!()
  end

  def data_set_type_menu do
    :io.setopts(:stdio, binary: true, echo: false)

    options = [
      "1. 教育なし Q and A",
      "2. キャンセル"
    ]

    Enum.each(options, &IO.puts/1)
    selection = IO.gets("番号を入力してください: ")
    data_set_type_handle_selection(String.trim(selection))
  end

  def data_set_type_handle_selection("1") do
    IO.puts("教育なし Q and Aを選択しました\n\n")
    start_instance_type_agent("qa")
    create_content()
    create_setting()
    LogManage.log("Created #{get_instance_path()}content.json", "INFO")
    IO.puts("データセットの作成が完了しました\n\n")
  end

  def data_set_type_handle_selection("2") do
    IO.puts("キャンセルしました\n\n")
    DataSetCollectorEs.show_menu()
  end

  defp start_instance_path_agent(name) do
    Agent.start_link(fn -> name end, name: :instance_path_agent)
  end

  defp get_instance_path do
    Agent.get(:instance_path_agent, fn name -> name end)
  end

  defp start_instance_name_agent(name) do
    Agent.start_link(fn -> name end, name: :instance_name_agent)
  end

  defp get_instance_name do
    Agent.get(:instance_name_agent, fn name -> name end)
  end

  defp start_instance_type_agent(type) do
    Agent.start_link(fn -> type end, name: :instance_type_agent)
  end

  defp get_instance_type do
    Agent.get(:instance_type_agent, fn type -> type end)
  end

  def create_data_set() do
    IO.puts("データセットを作成します\n\n")
    IO.puts("データセットの名前を入力してください\n")
    data_set_name = IO.gets(">> ")
    data_set_name = String.trim(data_set_name)
    start_instance_name_agent(data_set_name)

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

    setting = DataSetCollectorEs.read_settings()

    data_path = setting["data_path"]

    data_set_path = "#{data_path}/#{data_set_name}"
    start_instance_path_agent(data_set_path)

    if(not File.exists?(data_set_path)) do
      File.mkdir!(data_set_path)
    end

    IO.puts("データセットのタイプを選んでください\n")
    Task.shutdown(task)
    data_set_type_menu()
  end
end
