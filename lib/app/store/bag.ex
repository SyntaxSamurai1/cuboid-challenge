defmodule App.Store.Bag do
  @moduledoc """
  This module defines the Bag schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "bags" do
    field :title, :string
    field :volume, :integer
    field :payloadVolume, :integer, virtual: true, default: 0
    field :availableVolume, :integer, virtual: true, default: 0
    has_many :cuboids, App.Store.Cuboid

    timestamps()
  end

  @doc false
  def changeset(bag, attrs) do
    bag
    |> cast(attrs, [:volume, :title, :payloadVolume, :availableVolume])
    |> validate_required([:volume, :title])
  end

  # def assoc_changeset(bag, attrs) do
  #   IO.inspect(label: "here")
  #   bag
  #   |> cast(attrs, [:bag_id, :volume, :title, :payloadVolume, :availableVolume])
  #   |> set_payload()
  # end

  # def set_payload(%Ecto.Changeset{changes: %{payloadVolume: pv, volume: v}} = changeset) when pv > v do
  #   IO.inspect(changeset, label: "changeset!!!!")
  #   Ecto.Changeset.add_error(changeset, :payloadVolume, "Insufficient space in bag")
  # end
end
