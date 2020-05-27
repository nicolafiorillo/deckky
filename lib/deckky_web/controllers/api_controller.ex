defmodule DeckkyWeb.ApiController do
  use DeckkyWeb, :controller

  @spec status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def status(conn, _params), do: conn |> send_ok(%{})

  @spec pick_a_question(Plug.Conn.t(), map) :: Plug.Conn.t()
  def pick_a_question(conn, %{"argument_id" => _argument_id}) do
    conn |> send_ok(%{})
  end
end
