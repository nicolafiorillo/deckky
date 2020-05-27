defmodule DeckkyWeb.Router do
  use DeckkyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DeckkyWeb do
    pipe_through :api

    get "/", ApiController, :status
    get "/argument/:argument_id/pick", ApiController, :pick_a_question

    get "/card/:card_id/ok", ApiController, :set_correct
    get "/card/:card_id/error", ApiController, :set_error
  end
end
