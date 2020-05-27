defmodule DeckkyWeb.Response do
  import Plug.Conn
  alias Plug.Conn.Status

  @moduledoc false

  @spec send_ok(Plug.Conn.t(), any) :: Plug.Conn.t()
  def send_ok(conn, data \\ %{}), do: send(conn, Status.code(:ok), data)

  @spec send_bad_request(Plug.Conn.t(), any) :: Plug.Conn.t()
  def send_bad_request(conn, data), do: send(conn, Status.code(:bad_request), data)

  @spec send(Plug.Conn.t(), integer, any) :: Plug.Conn.t()
  defp send(conn, code, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(code, data |> Jason.encode!())
  end
end
