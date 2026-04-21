defmodule DynamicRovers do
  @moduledoc """
  Public API for the dynamic rovers lesson.
  """

  alias DynamicRovers.{HabitatFleet, LifeSupportUnit, Rover, RoverSupervisor}

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def service_pid(service) do
    case Registry.lookup(DynamicRovers.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(DynamicRovers.Registry, {habitat_id, subsystem}) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def induce_failure(habitat_id, subsystem) do
    with {:ok, pid} <- subsystem_pid(habitat_id, subsystem) do
      LifeSupportUnit.induce_failure(pid)
    end
  end

  def launch_rover(id, opts \\ []) when is_binary(id) do
    RoverSupervisor.launch_rover(id, opts)
  end

  def lookup_rover(id) do
    case Registry.lookup(DynamicRovers.Registry, id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def rover_status(id) when is_binary(id) do
    with {:ok, pid} <- lookup_rover(id) do
      {:ok, Rover.status(pid)}
    end
  end

  def assign_mission(id, mission) when is_binary(id) and is_binary(mission) do
    with {:ok, pid} <- lookup_rover(id) do
      Rover.assign_mission(pid, mission)
    end
  end

  def retire_rover(id) when is_binary(id) do
    with {:ok, pid} <- lookup_rover(id) do
      monitor = Process.monitor(pid)
      :ok = DynamicSupervisor.terminate_child(DynamicRovers.RoverSupervisor, pid)

      receive do
        {:DOWN, ^monitor, :process, ^pid, _reason} -> await_rover_removal(id)
      after
        100 -> await_rover_removal(id)
      end
    end
  end

  defp await_rover_removal(id) do
    Enum.reduce_while(1..10, :ok, fn _, _acc ->
      case lookup_rover(id) do
        :error ->
          {:halt, :ok}

        _ ->
          Process.sleep(10)
          {:cont, :ok}
      end
    end)
  end
end
