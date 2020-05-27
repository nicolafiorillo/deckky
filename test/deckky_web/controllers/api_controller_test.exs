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
    test "pick_a_question", %{conn: conn} do
      conn = get(conn, Routes.api_path(conn, :pick_a_question, "5D70573F-6FAB-459F-AE85-4F5A4B4B6A0C"))
      assert json_response(conn, 200)
      # check question
    end
  end
end
