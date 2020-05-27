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
end
