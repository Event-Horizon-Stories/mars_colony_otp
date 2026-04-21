defmodule LifeSupportSupervision do
  @moduledoc """
  Public API for the habitat supervision lesson.
  """

  alias LifeSupportSupervision.HabitatFleet
  alias LifeSupportSupervision.LifeSupportUnit

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(LifeSupportSupervision.Registry, {habitat_id, subsystem}) do
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
