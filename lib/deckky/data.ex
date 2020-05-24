defmodule Deckky.Data do
  @moduledoc """
  Data loader
  """
  use GenServer
  require Logger

  defstruct groups: [], results: %{}

  def start_link(_opts \\ []) do
    folder = Path.join(File.cwd!(), "data/")
    {:ok, files} = folder |> File.ls()
    groups = files |> Enum.map(fn f -> Path.join(folder, f) end)

    GenServer.start_link(__MODULE__, groups, name: __MODULE__)
  end

  # Init
  def init(groups) do

    groups =
      groups
      |> read_groups()
      |> sort_by_counter()

    {:ok, %Deckky.Data{groups: groups}}
  end

  # Api
  @spec groups :: any
  def groups(), do: GenServer.call(__MODULE__, :get_groups)

  @spec results :: any
  def results(), do: GenServer.call(__MODULE__, :get_results)

  @spec random_card :: any
  def random_card(), do: GenServer.call(__MODULE__, :random_card)

  @spec set_correct(String, String) :: any
  def set_correct(group_id, card_id), do: GenServer.cast(__MODULE__, {:set_correct, group_id, card_id})

  @spec set_error(String, String) :: any
  def set_error(group_id, card_id), do: GenServer.cast(__MODULE__, {:set_error, group_id, card_id})

  # Callbacks
  def handle_call(:get_groups, _from, %Deckky.Data{groups: groups} = state), do: {:reply, groups, state}

  def handle_call(:get_results, _from, %Deckky.Data{results: results} = state), do: {:reply, results, state}

  def handle_call(:random_card, _from, %Deckky.Data{groups: groups, results: results} = state) do
    group = groups |> Enum.random()
    card =
      group["cards"]
      |> Enum.random()
      |> Map.put("group_id", group["group_id"])
      |> Map.put("group_title", group["title"])

    results = results |> add_popped(group["group_id"], card["card_id"])

    {:reply, card, %Deckky.Data{state | results: results}}
  end

  def handle_cast({:set_correct, group_id, card_id}, %Deckky.Data{results: results} = state) do
    results = results |> add_correct_result(group_id, card_id)
    {:noreply, %Deckky.Data{state | results: results}}
  end

  def handle_cast({:set_error, group_id, card_id}, %Deckky.Data{results: results} = state) do
    results = results |> add_error_result(group_id, card_id)
    {:noreply, %Deckky.Data{state | results: results}}
  end

  # Helpers
  defp read_groups(groups) do
    Logger.info("Reading #{length(groups)} groups.")

    Enum.reduce(groups, [], fn f, groups ->
      {:ok, group} = YamlElixir.read_from_file(f)
      [group | groups]
    end)
  end

  defp sort_by_counter(groups) do
    Enum.sort(groups, fn left, right -> Map.fetch!(left, "counter") < Map.fetch!(right, "counter") end)
  end

  defp add_popped(results, group_id, card_id) do
    results |> Map.update(group_id, %{card_id => %{popped: 1, corrects: 0, errors: 0}}, fn result_group ->
      result_group |> Map.update(card_id, %{popped: 1, corrects: 0, errors: 0}, fn %{popped: popped} = result_card ->
        %{result_card | popped: popped + 1}
      end)
    end)
  end

  defp add_correct_result(results, group_id, card_id) do
    results |> Map.update!(group_id, fn result_group ->
      result_group |> Map.update!(card_id, fn %{corrects: corrects} = result_card ->
        %{result_card | corrects: corrects + 1}
      end)
    end)
  end

  defp add_error_result(results, group_id, card_id) do
    results |> Map.update!(group_id, fn result_group ->
      result_group |> Map.update!(card_id, fn %{errors: errors} = result_card ->
        %{result_card | errors: errors + 1}
      end)
    end)
  end
end
