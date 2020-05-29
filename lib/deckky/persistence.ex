defmodule Deckky.Persistence do

  @moduledoc """
  Storing results.
  """
  use GenServer
  require Logger
  require Injex

  @persistence Injex.resolve(:persistence)

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :deckky_storage, opts ++ [name: __MODULE__])
  end

  @spec init(atom) :: {:ok, any}
  def init(table_name) do
    table = @persistence.open(table_name)
    Logger.info("Persistence started")
    {:ok, %{table: table}}
  end

  @spec increment_picked(bitstring) :: any
  def increment_picked(card_id), do: GenServer.call(__MODULE__, {:increment_picked, card_id})

  @spec increment_correct(bitstring) :: any
  def increment_correct(card_id), do: GenServer.call(__MODULE__, {:increment_correct, card_id})

  @spec increment_error(bitstring) :: any
  def increment_error(card_id), do: GenServer.call(__MODULE__, {:increment_error, card_id})

  @spec results() :: any
  def results(), do: GenServer.call(__MODULE__, :results)

  #
  # Callbacks
  #
  def handle_call(:results, _from, %{table: table} = state) do
    results =
      @persistence.match(table, {:"$1", :"$2"})
      |> Enum.map(fn [id, [p, c, e]] -> %{id: id, p: p, c: c, e: e} end)

    {:reply, results, state}
  end

  def handle_call({:increment_picked, card_id}, _from, %{table: table} = state) do
    case @persistence.lookup(table, card_id) do
      [] -> @persistence.insert_new(table, {card_id, [1, 0, 0]})
      [{card_id, [picked, corrects, errors]}] -> @persistence.insert(table, {card_id, [picked + 1, corrects, errors]})
    end

    {:reply, :ok, state}
  end

  def handle_call({:increment_correct, card_id}, _from, %{table: table} = state) do
    case @persistence.lookup(table, card_id) do
      [] -> @persistence.insert_new(table, {card_id, [0, 1, 0]})
      [{card_id, [picked, corrects, errors]}] -> @persistence.insert(table, {card_id, [picked, corrects + 1, errors]})
    end

    {:reply, :ok, state}
  end

  def handle_call({:increment_error, card_id}, _from, %{table: table} = state) do
    case @persistence.lookup(table, card_id) do
      [] -> @persistence.insert_new(table, {card_id, [0, 0, 1]})
      [{card_id, [picked, corrects, errors]}] -> @persistence.insert(table, {card_id, [picked, corrects, errors + 1]})
    end

    {:reply, :ok, state}
  end

  def terminate(_reason, %{table: table}) do
    Logger.info("Closing peristence")
    @persistence.close(table)
  end
end
