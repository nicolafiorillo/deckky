defmodule DeckkyWeb.PageController do
  use DeckkyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
