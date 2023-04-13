defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :api
    resources "/cuboids", CuboidController, only: [:index, :create, :show, :delete, :update]
    resources "/bags", BagController, only: [:index, :create, :show]
  end
end
