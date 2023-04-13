defmodule App.Store.Cuboid do
  @moduledoc """
  This module defines the Cuboid schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "cuboids" do
    field :depth, :integer
    field :height, :integer
    field :width, :integer
    field :volume, :integer, virtual: true, default: 0
    belongs_to :bag, App.Store.Bag

    timestamps()
  end

  @doc false
  def changeset(cuboid, attrs) do
    cuboid
    |> cast(attrs, [:width, :height, :depth, :bag_id, :volume])
    |> validate_required([:width, :height, :depth])
    |> assoc_constraint(:bag, require: true)
    |> cast_assoc(:bag, with: &App.Store.Bag.changeset/2)
    |> set_volume()
    |> validate_capacity()
  end

  def set_volume(
        %Ecto.Changeset{
          valid?: false
        } = changeset
      ),
      do: changeset

  def set_volume(%Ecto.Changeset{changes: changes} = changeset) do
    put_change(
      changeset,
      :volume,
      changes.width * changes.height * changes.depth
    )
  end

  def validate_capacity(%Ecto.Changeset{changes: changes} = changeset) do
    get_field(changeset, :bag)
    |> case do
      nil ->
        changeset

      bag_volume ->
        if bag_volume.volume < changes.volume do
          Ecto.Changeset.add_error(changeset, :volume, "Insufficient space in bag")
        else
          changeset
        end
    end
  end
end
