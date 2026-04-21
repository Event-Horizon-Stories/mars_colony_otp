defmodule LifeSupportSupervision.HabitatFleet do
  @moduledoc """
  Starts habitat supervision trees as the colony grows.

  This module is a `DynamicSupervisor` because habitats are created at runtime.
  Each child it starts is not one worker, but a whole `HabitatSupervisor` tree.
  """

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_habitat(id) do
    # Each new habitat gets its own subtree of life-support processes.
    DynamicSupervisor.start_child(__MODULE__, {LifeSupportSupervision.HabitatSupervisor, id})
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
