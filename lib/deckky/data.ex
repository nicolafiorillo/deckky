defmodule Deckky.Data do
  @moduledoc """
  Data loader
  """
  use GenServer

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

    {:ok, %{groups: groups}}

  end

  # Api
  @spec get_groups :: any
  def get_groups(), do: GenServer.call(__MODULE__, :get_groups)

  # Callbacks
  def handle_call(:get_groups, _from, %{groups: groups} = state) do
    {:reply, groups, state}
  end

  # Helpers
  defp read_groups(groups) do
    Enum.reduce(groups, [], fn f, groups ->
    IO.inspect f
      {:ok, group} = YamlElixir.read_from_file(f)
      [group | groups]
    end)
  end

  defp sort_by_counter(groups) do
    Enum.sort(groups, fn left, right -> Map.fetch!(left, "counter") >= Map.fetch!(right, "counter") end)
  end
end
