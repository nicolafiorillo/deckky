defmodule Deckky.Persistence.Disk do
  @spec open(any) :: {:error, any} | {:ok, any}
  def open(storage) do
    {:ok, table} = :dets.open_file(storage, [type: :set])
    table
  end

  @spec match(any, atom | tuple) :: [[any]] | {:error, any}
  def match(storage, filter), do: :dets.match(storage, filter)

  @spec lookup(any, any) :: [tuple] | {:error, any}
  def lookup(storage, key), do: :dets.lookup(storage, key)

  @spec insert_new(any, [tuple] | tuple) :: boolean | {:error, any}
  def insert_new(storage, item), do: :dets.insert_new(storage, item)

  @spec insert(any, [tuple] | tuple) :: :ok | {:error, any}
  def insert(storage, item), do: :dets.insert(storage, item)

  @spec close(any) :: :ok | {:error, any}
  def close(storage), do: :dets.close(storage)
end
