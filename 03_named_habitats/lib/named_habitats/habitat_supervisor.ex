defmodule NamedHabitats.HabitatSupervisor do
  @moduledoc """
  Starts habitat processes on demand.

  `DynamicSupervisor` is a good fit when the application does not know every
  child ahead of time. New habitats can appear during runtime, so they are a
  better fit here than a fixed child list in a normal supervisor.
  """

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_habitat(id, opts) do
    # Build the child spec at runtime because the habitat ID is only known now.
    child_spec = {NamedHabitats.Habitat, Keyword.merge(opts, id: id)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
