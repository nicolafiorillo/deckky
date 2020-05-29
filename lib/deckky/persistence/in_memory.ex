defmodule Deckky.Persistence.InMemory do
  def open(storage) do
    :ets.new(storage, [:set, :protected, :named_table])
    storage
  end

  @spec match(any, atom | tuple) :: [[any]] | {:error, any}
  def match(storage, filter), do: :ets.match(storage, filter)

  @spec lookup(any, any) :: [tuple] | {:error, any}
  def lookup(storage, key), do: :ets.lookup(storage, key)

  def insert_new(storage, item), do: :ets.insert_new(storage, item)

  @spec insert(atom | :ets.tid(), [tuple] | tuple) :: true
  def insert(storage, item), do: :ets.insert(storage, item)

  @spec close(any) :: :ok
  def close(_storage), do: :ok
end
