defmodule PersistentShiftHandoff do
  @moduledoc """
  Public API for the persistent shift handoff lesson.
  """

  alias PersistentShiftHandoff.{
    Commander,
    HabitatFleet,
    HandoffLog,
    LifeSupportUnit,
    MaintenanceQueue,
    RoutePlanner,
    Rover,
    RoverSupervisor
  }

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def service_pid(service) do
    case Registry.lookup(PersistentShiftHandoff.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(PersistentShiftHandoff.Registry, {habitat_id, subsystem}) do
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
    case Registry.lookup(PersistentShiftHandoff.Registry, id) do
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
      DynamicSupervisor.terminate_child(PersistentShiftHandoff.RoverSupervisor, pid)
    end
  end

  def plan_route_async(route_request), do: RoutePlanner.plan_route_async(route_request)
  def await_plan(task, timeout), do: RoutePlanner.await_plan(task, timeout)

  def subscribe(topic), do: PersistentShiftHandoff.AlertBus.subscribe(topic)
  def publish(topic, payload), do: PersistentShiftHandoff.AlertBus.publish(topic, payload)

  def enqueue_request(request), do: MaintenanceQueue.enqueue(request)
  def dispatch_next, do: MaintenanceQueue.dispatch_next()
  def ack_request(id), do: MaintenanceQueue.ack(id)

  def queue_snapshot do
    MaintenanceQueue.snapshot().queued
  end

  def start_sensor_pipeline(opts) do
    producer_name = Keyword.get(opts, :producer_name, PersistentShiftHandoff.SensorProducer)
    notify = Keyword.fetch!(opts, :notify)

    {:ok, producer} = PersistentShiftHandoff.SensorProducer.start_link(name: producer_name)
    {:ok, normalizer} = PersistentShiftHandoff.Normalizer.start_link(upstream: producer)

    {:ok, sink} =
      PersistentShiftHandoff.AnomalySink.start_link(upstream: normalizer, notify: notify)

    {:ok, %{producer: producer, normalizer: normalizer, sink: sink}}
  end

  def publish_sensor_packet(packet, producer \\ PersistentShiftHandoff.SensorProducer) do
    PersistentShiftHandoff.SensorProducer.publish(producer, packet)
  end

  def start_pipeline(opts) do
    notify = Keyword.fetch!(opts, :notify)
    pipeline_name = Keyword.get(opts, :name, PersistentShiftHandoff.Pipeline)
    PersistentShiftHandoff.Pipeline.start_link(name: pipeline_name, notify: notify)
  end

  def push_event(event, pipeline_name \\ PersistentShiftHandoff.Pipeline) do
    PersistentShiftHandoff.Producer.push_event(producer_stage_name(pipeline_name), event)
  end

  def report_alert(alert) do
    PersistentShiftHandoff.AlertBus.publish(:critical_alerts, alert)
  end

  def incident_snapshot, do: Commander.snapshot()

  def start_link(opts), do: HandoffLog.start_link(opts)
  def record_summary(server, summary), do: HandoffLog.record_summary(server, summary)
  def snapshot(server), do: HandoffLog.snapshot(server)

  defp producer_stage_name(pipeline_name) do
    Module.concat([pipeline_name, "Broadway", "Producer_0"])
  end
end
