defmodule AppWeb.CuboidController do
  use AppWeb, :controller

  alias App.Store
  alias App.Store.Cuboid

  action_fallback AppWeb.FallbackController

  def index(conn, _params) do
    cuboids = Store.list_cuboids()
    render(conn, "index.json", cuboids: cuboids)
  end

  def create(conn, cuboid_params) do
    bag = Store.get_bag(cuboid_params["bag_id"])

    if bag.volume > cuboid_params["depth"] * cuboid_params["height"] * cuboid_params["width"] do
      with {:ok, %Cuboid{} = cuboid} <- Store.create_cuboid(cuboid_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.cuboid_path(conn, :show, cuboid))
        |> render("show.json", cuboid: cuboid)
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: %{volume: ["Insufficient space in bag"]}})
    end
  end

  def show(conn, %{"id" => id}) do
    case Store.get_cuboid(id) do
      nil -> conn |> send_resp(404, "")
      cuboid -> render(conn, "show.json", cuboid: cuboid)
    end
  end

  def delete(conn, %{"id" => id}) do
    Store.delete_cuboid(id)
    |> case do
      {:ok, cuboid} ->
        conn
        |> render("show.json", cuboid: cuboid)

      {:error, error} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: error})
    end
  end

  def update(conn, %{"id" => id} = params) do
    with cuboid <- Store.get_cuboid(id),
         {:ok, cuboid} <- Store.update_cuboid(cuboid, params) do
      conn
      |> render("cuboid.json", cuboid: cuboid)
    end
  end
end
