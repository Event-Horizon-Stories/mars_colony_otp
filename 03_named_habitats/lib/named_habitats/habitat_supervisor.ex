defmodule NamedHabitats.HabitatSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_habitat(id, opts) do
    child_spec = {NamedHabitats.Habitat, Keyword.merge(opts, id: id)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
