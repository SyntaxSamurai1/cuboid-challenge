defmodule App.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Store.Cuboid

  @doc """
  Returns the list of cuboids.

  ## Examples

      iex> list_cuboids()
      [%Cuboid{}, ...]

  """
  def list_cuboids do
    Cuboid |> get_cuboid_volume() |> Repo.all() |> Repo.preload(:bag)
  end

  @doc """
  Gets a single cuboid.

  Raises if the Cuboid does not exist.

  ## Examples

      iex> get_cuboid!(123)
      %Cuboid{}

  """
  def get_cuboid(id),
    do:
      Cuboid
      |> get_cuboid_volume()
      |> Repo.get(id)
      |> Repo.preload(:bag)

  def get_cuboid_volume(query \\ Cuboid),
    do: select_merge(query, [c], %{volume: c.depth * c.height * c.width})

  @doc """
  Creates a cuboid.

  ## Examples

      iex> create_cuboid(%{field: value})
      {:ok, %Cuboid{}}

      iex> create_cuboid(%{field: bad_value})
      {:error, ...}

  """
  def create_cuboid(attrs \\ %{}) do
    %Cuboid{}
    |> Cuboid.changeset(attrs)
    |> Repo.insert()
  end

  alias App.Store.Bag

  @doc """
  Returns the list of bags.

  ## Examples

      iex> list_bags()
      [%Bag{}, ...]

  """

  def delete_cuboid(cuboid) do
    Repo.get(Cuboid, cuboid)
    |> case do
      nil -> {:error, "No cuboid found"}
      cuboid -> Repo.delete(cuboid)
    end
  end

  # def delete_cuboid(cuboid), do: Repo.delete(cuboid)
  #   Repo.get_by(Cuboid, cuboid.id)
  #   |> case do
  #     nil -> {:error, "No cuboid"}
  #     cuboid -> Repo.delete(cuboid)
  #   end
  # end

  def update_cuboid(%Cuboid{} = cuboid, attrs) do
    cuboid
    |> Cuboid.changeset(attrs)
    |> Repo.update()
  end

  def list_bags do
    Repo.all(Bag)
    |> Repo.preload(:cuboids)
    |> Enum.map(fn bag ->
      set_bag_volumes(bag)
    end)
  end

  @doc """
  Gets a single bag.

  Raises if the Bag does not exist.

  ## Examples

      iex> get_bag!(123)
      %Bag{}

  """
  def get_bag(id) do
    bag = Repo.get(Bag, id) |> Repo.preload(:cuboids)
    set_bag_volumes(bag)
  end

  defp set_bag_volumes(bag) do
    payload_volume = bag.cuboids |> Enum.map(&(&1.depth * &1.height * &1.width)) |> Enum.sum()

    Map.merge(bag, %{payloadVolume: payload_volume, availableVolume: bag.volume - payload_volume})
  end

  @doc """
  Creates a bag.

  ## Examples

      iex> create_bag(%{field: value})
      {:ok, %Bag{}}

      iex> create_bag(%{field: bad_value})
      {:error, ...}

  """
  def create_bag(attrs \\ %{}) do
    %Bag{}
    |> Bag.changeset(attrs)
    |> Repo.insert()
  end
end
