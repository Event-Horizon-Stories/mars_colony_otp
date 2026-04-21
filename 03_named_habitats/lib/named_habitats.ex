defmodule NamedHabitats do
  @moduledoc """
  Public API for the named habitats lesson.
  """

  alias NamedHabitats.Habitat
  alias NamedHabitats.HabitatSupervisor

  def start_habitat(id, opts \\ []) when is_binary(id) do
    HabitatSupervisor.start_habitat(id, opts)
  end

  def lookup_habitat(id) when is_binary(id) do
    case Registry.lookup(NamedHabitats.Registry, id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def get_status(id) when is_binary(id) do
    with {:ok, pid} <- lookup_habitat(id) do
      {:ok, Habitat.get_status(pid)}
    end
  end
end
