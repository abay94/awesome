defmodule AwesomeWeb.Router do
  use AwesomeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end


  scope "/", AwesomeWeb do
    pipe_through :browser

    get "/", GroupController, :index
  end

end
