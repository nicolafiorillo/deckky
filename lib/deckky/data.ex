defmodule Deckky.Data do
  @moduledoc """
  Data loader
  """
  use GenServer
  require Logger

  @type t :: %__MODULE__{}

  defstruct arguments: %{}, results: %{}

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts \\ []) do
    folder = Path.join(:code.priv_dir(:deckky), "data/")
    {:ok, folders} = folder |> File.ls()
    arguments =
      folders
      |> Enum.map(fn f -> Path.join(folder, f) end)
      |> Enum.filter(fn d -> File.dir?(d) end)

    GenServer.start_link(__MODULE__, arguments, name: __MODULE__)
  end

  # Init
  @spec init(any) :: {:ok, Deckky.Data.t()}
  def init(arguments) do
    arguments =
      arguments
        |> Enum.reduce(%{}, fn folder, acc ->
          {:ok, files} = folder |> File.ls()
          groups =
            files
            |> Enum.map(fn f -> Path.join(folder, f) end)
            |> read_groups()
            |> sort_by_counter()
          argument = Path.basename(folder)
          Map.put(acc, argument, groups)
        end)

    {:ok, %Deckky.Data{arguments: arguments}}
  end

  # Api
  @spec groups(bitstring) :: any
  def groups(argument_id), do: GenServer.call(__MODULE__, {:get_groups, argument_id})

  @spec results :: any
  def results(), do: GenServer.call(__MODULE__, :get_results)

  @spec random_card(bitstring) :: any
  def random_card(argument_id), do: GenServer.call(__MODULE__, {:random_card, argument_id})

  @spec set_correct(String) :: any
  def set_correct(card_id), do: GenServer.cast(__MODULE__, {:set_correct, card_id})

  @spec set_error(String) :: any
  def set_error(card_id), do: GenServer.cast(__MODULE__, {:set_error, card_id})

  # Callbacks
  def handle_call({:get_groups, argument_id}, _from, %Deckky.Data{arguments: arguments} = state) do
    {:reply, get_argument_groups(arguments, argument_id), state}
  end

  def handle_call(:get_results, _from, %Deckky.Data{results: results} = state), do: {:reply, results, state}

  def handle_call({:random_card, argument_id}, _from, %Deckky.Data{arguments: arguments, results: results} = state) do
    arguments
    |> get_argument_groups(argument_id)
    |> pick_a_card(results)
    |> case do
      {:error, _} = err -> {:reply, err, state}
      {:ok, card, results} -> {:reply, {:ok, card}, %Deckky.Data{state | results: results}}
    end
  end

  def handle_cast({:set_correct, card_id}, %Deckky.Data{results: results} = state) do
    results = results |> add_correct_result(card_id)
    {:noreply, %Deckky.Data{state | results: results}}
  end

  def handle_cast({:set_error, card_id}, %Deckky.Data{results: results} = state) do
    results = results |> add_error_result(card_id)
    {:noreply, %Deckky.Data{state | results: results}}
  end

  # Helpers
  defp pick_a_card({:ok, []}, _results), do: {:error, "no groups in argument"}
  defp pick_a_card({:ok, groups}, results) do
    group = groups |> Enum.random()
    card =
      group["cards"]
      |> Enum.random()
      |> Map.put("group_id", group["group_id"])
      |> Map.put("group_title", group["title"])

    {:ok, card, results |> picked(card["card_id"])}
  end
  defp pick_a_card({:error, _} = err, _results), do: err

  defp get_argument_groups(arguments, argument_id) do
    case Map.get(arguments, argument_id) do
      nil -> {:error, "argument not found"}
      groups -> {:ok, groups}
    end
  end

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

  defp picked(results, card_id) do
    results |> Map.update(card_id, %{popped: 1, corrects: 0, errors: 0}, fn %{popped: popped} = result_card ->
      %{result_card | popped: popped + 1}
    end)
  end

  defp add_correct_result(results, card_id) do
    results |> Map.update(card_id, %{popped: 0, corrects: 1, errors: 0}, fn %{corrects: corrects} = result_card ->
      %{result_card | corrects: corrects + 1}
    end)
  end

  defp add_error_result(results, card_id) do
    results |> Map.update(card_id, %{popped: 1, corrects: 0, errors: 1}, fn %{errors: errors} = result_card ->
      %{result_card | errors: errors + 1}
    end)
  end
end
