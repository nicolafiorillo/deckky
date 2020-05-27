defmodule DeckkyWeb.ApiController do
  use DeckkyWeb, :controller

  @spec status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def status(conn, _params), do: conn |> send_ok(%{})

  @spec pick_a_question(Plug.Conn.t(), map) :: Plug.Conn.t()
  def pick_a_question(conn, %{"argument_id" => argument_id}) do
    Deckky.Data.random_card(argument_id)
    |> send_response(conn)
  end

  @spec set_correct(Plug.Conn.t(), map) :: Plug.Conn.t()
  def set_correct(conn, %{"card_id" => card_id}) do
    Deckky.Data.set_correct(card_id)
    conn |> send_ok()
  end

  @spec set_error(Plug.Conn.t(), map) :: Plug.Conn.t()
  def set_error(conn, %{"card_id" => card_id}) do
    Deckky.Data.set_error(card_id)
    conn |> send_ok()
  end

  defp send_response({:ok, card}, conn), do: conn |> send_ok(%{card: card})
  defp send_response({:error, message}, conn), do: conn |> send_bad_request(%{error: message})
end
