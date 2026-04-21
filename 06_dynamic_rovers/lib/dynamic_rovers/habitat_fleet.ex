defmodule DynamicRovers.HabitatFleet do
  @moduledoc false

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_habitat(id) do
    DynamicSupervisor.start_child(__MODULE__, {DynamicRovers.HabitatSupervisor, id})
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
