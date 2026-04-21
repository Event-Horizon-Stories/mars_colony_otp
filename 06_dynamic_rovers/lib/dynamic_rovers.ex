defmodule DynamicRovers do
  @moduledoc """
  Public API for the dynamic rover lesson.
  """

  alias DynamicRovers.Rover
  alias DynamicRovers.RoverSupervisor

  def launch_rover(id, opts \\ []) when is_binary(id) do
    RoverSupervisor.launch_rover(id, opts)
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
        {:DOWN, ^monitor, :process, ^pid, _reason} -> :ok
      after
        100 -> :ok
      end
    end
  end

  def lookup_rover(id) do
    case Registry.lookup(DynamicRovers.Registry, id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end
end
