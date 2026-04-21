defmodule BackpressureAndQueues do
  @moduledoc """
  Public API for the backpressure and queues lesson.
  """

  alias BackpressureAndQueues.{
    HabitatFleet,
    LifeSupportUnit,
    MaintenanceQueue,
    RoutePlanner,
    Rover,
    RoverSupervisor
  }

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def service_pid(service) do
    case Registry.lookup(BackpressureAndQueues.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(BackpressureAndQueues.Registry, {habitat_id, subsystem}) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def induce_failure(habitat_id, subsystem) do
    with {:ok, pid} <- subsystem_pid(habitat_id, subsystem) do
      LifeSupportUnit.induce_failure(pid)
    end
  end

  def launch_rover(id, opts \\ []), do: RoverSupervisor.launch_rover(id, opts)

  def lookup_rover(id) do
    case Registry.lookup(BackpressureAndQueues.Registry, id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def rover_status(id) do
    with {:ok, pid} <- lookup_rover(id) do
      {:ok, Rover.status(pid)}
    end
  end

  def assign_mission(id, mission) do
    with {:ok, pid} <- lookup_rover(id) do
      Rover.assign_mission(pid, mission)
    end
  end

  def retire_rover(id) do
    with {:ok, pid} <- lookup_rover(id) do
      DynamicSupervisor.terminate_child(BackpressureAndQueues.RoverSupervisor, pid)
    end
  end

  def plan_route_async(route_request), do: RoutePlanner.plan_route_async(route_request)
  def await_plan(task, timeout), do: RoutePlanner.await_plan(task, timeout)

  def subscribe(topic) when is_atom(topic) do
    Registry.register(BackpressureAndQueues.AlertRegistry, topic, [])
  end

  def publish(topic, payload) when is_atom(topic) do
    Registry.dispatch(BackpressureAndQueues.AlertRegistry, topic, fn entries ->
      for {pid, _meta} <- entries do
        send(pid, {:colony_alert, topic, payload})
      end
    end)
  end

  def enqueue_request(request), do: MaintenanceQueue.enqueue(request)
  def dispatch_next, do: MaintenanceQueue.dispatch_next()
  def ack_request(id), do: MaintenanceQueue.ack(id)
  def snapshot, do: MaintenanceQueue.snapshot()
end
