defmodule ColonyControlTree do
  @moduledoc """
  Public API for the colony control tree lesson.
  """

  alias ColonyControlTree.HabitatFleet
  alias ColonyControlTree.LifeSupportUnit

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def service_pid(service) do
    case Registry.lookup(ColonyControlTree.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(ColonyControlTree.Registry, {habitat_id, subsystem}) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def induce_failure(habitat_id, subsystem) do
    with {:ok, pid} <- subsystem_pid(habitat_id, subsystem) do
      LifeSupportUnit.induce_failure(pid)
    end
  end
end
