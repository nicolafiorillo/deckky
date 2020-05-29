defmodule DeckkyWeb.PApiControllerTest do
  use DeckkyWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "health" do
    test "status", %{conn: conn} do
      conn = get(conn, Routes.api_path(conn, :status))
      assert json_response(conn, 200)
    end
  end

  describe "argument" do
    test "pick a question", %{conn: conn} do
      conn = get(conn, Routes.api_path(conn, :pick_a_question, "5D70573F-6FAB-459F-AE85-4F5A4B4B6A0C"))
      assert json_response(conn, 200)["card"]
    end

    test "invalid argument", %{conn: conn} do
      conn = get(conn, Routes.api_path(conn, :pick_a_question, "ABC123"))
      assert json_response(conn, 400)["error"] == "argument not found"
    end
  end

  describe "card" do
    test "send ok", %{conn: conn} do
      card_id = "6603C14E-38B6-4DE4-AE97-B5923CAB9708"

      conn = get(conn, Routes.api_path(conn, :set_correct, card_id))
      assert json_response(conn, 200)
      :timer.sleep(100)

      card = Deckky.Data.results() |> find_card(card_id)

      assert card.c == 1
      assert card.e == 0
    end

    defp find_card(cards, card_id), do: Enum.find(cards, fn c -> c.id == card_id end)

    test "send error", %{conn: conn} do
      card_id = "33EEDC93-F7EA-4117-9526-2A365DEC0883"

      conn = get(conn, Routes.api_path(conn, :set_error, card_id))
      assert json_response(conn, 200)
      :timer.sleep(100)

      card = Deckky.Data.results() |> find_card(card_id)

      assert card.c == 0
      assert card.e == 1
    end
  end
end
