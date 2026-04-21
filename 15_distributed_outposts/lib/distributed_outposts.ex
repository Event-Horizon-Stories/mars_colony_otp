defmodule DistributedOutposts do
  @moduledoc """
  Public API for the distributed outposts lesson.

  This chapter keeps the full single-node colony from lesson 14 and adds one
  new pressure: another node has appeared in the field, and mission control
  needs a clean way to talk to it.
  """

  alias DistributedOutposts.{
    Commander,
    HabitatFleet,
    HandoffLog,
    LifeSupportUnit,
    MaintenanceQueue,
    OutpostBeacon,
    RoutePlanner,
    Rover,
    RoverSupervisor
  }

  def start_habitat(id), do: HabitatFleet.start_habitat(id)

  def service_pid(service) do
    case Registry.lookup(DistributedOutposts.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end

  def subsystem_pid(habitat_id, subsystem) do
    case Registry.lookup(DistributedOutposts.Registry, {habitat_id, subsystem}) do
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
    case Registry.lookup(DistributedOutposts.Registry, id) do
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
      DynamicSupervisor.terminate_child(DistributedOutposts.RoverSupervisor, pid)
    end
  end

  def plan_route_async(route_request), do: RoutePlanner.plan_route_async(route_request)
  def await_plan(task, timeout), do: RoutePlanner.await_plan(task, timeout)

  def subscribe(topic), do: DistributedOutposts.AlertBus.subscribe(topic)
  def publish(topic, payload), do: DistributedOutposts.AlertBus.publish(topic, payload)

  def enqueue_request(request), do: MaintenanceQueue.enqueue(request)
  def dispatch_next, do: MaintenanceQueue.dispatch_next()
  def ack_request(id), do: MaintenanceQueue.ack(id)

  def queue_snapshot do
    MaintenanceQueue.snapshot().queued
  end

  def start_sensor_pipeline(opts) do
    producer_name = Keyword.get(opts, :producer_name, DistributedOutposts.SensorProducer)
    notify = Keyword.fetch!(opts, :notify)

    {:ok, producer} = DistributedOutposts.SensorProducer.start_link(name: producer_name)
    {:ok, normalizer} = DistributedOutposts.Normalizer.start_link(upstream: producer)

    {:ok, sink} =
      DistributedOutposts.AnomalySink.start_link(upstream: normalizer, notify: notify)

    {:ok, %{producer: producer, normalizer: normalizer, sink: sink}}
  end

  def publish_sensor_packet(packet, producer \\ DistributedOutposts.SensorProducer) do
    DistributedOutposts.SensorProducer.publish(producer, packet)
  end

  def start_pipeline(opts) do
    notify = Keyword.fetch!(opts, :notify)
    pipeline_name = Keyword.get(opts, :name, DistributedOutposts.Pipeline)
    DistributedOutposts.Pipeline.start_link(name: pipeline_name, notify: notify)
  end

  def push_event(event, pipeline_name \\ DistributedOutposts.Pipeline) do
    DistributedOutposts.Producer.push_event(producer_stage_name(pipeline_name), event)
  end

  def report_alert(alert) do
    DistributedOutposts.AlertBus.publish(:critical_alerts, alert)
  end

  def incident_snapshot, do: Commander.snapshot()

  def start_link(opts), do: HandoffLog.start_link(opts)
  def record_summary(server, summary), do: HandoffLog.record_summary(server, summary)
  def snapshot(server), do: HandoffLog.snapshot(server)

  def connect_outpost(node_name) when is_atom(node_name) do
    with true <- Node.connect(node_name),
         :ok <- ensure_local_outpost_registered(node()),
         :ok <- ensure_remote_outpost_registered(node_name),
         :ok <- :global.sync() do
      true
    else
      false -> {:error, :node_unreachable}
      :ignored -> {:error, :connection_ignored}
      {:error, _reason} = error -> error
    end
  end

  def connected_outposts do
    Node.list()
  end

  def remote_incident_snapshot(node_name) when is_atom(node_name) do
    :rpc.call(node_name, __MODULE__, :incident_snapshot, [])
  end

  def remote_queue_snapshot(node_name) when is_atom(node_name) do
    :rpc.call(node_name, __MODULE__, :queue_snapshot, [])
  end

  def remote_cluster_snapshot(node_name) when is_atom(node_name) do
    :rpc.call(node_name, __MODULE__, :local_cluster_snapshot, [])
  end

  def register_outpost(outpost_id \\ node()) when is_atom(outpost_id) do
    OutpostBeacon.register_global(outpost_id)
  end

  def outpost_snapshot(outpost_id) when is_atom(outpost_id) do
    case lookup_outpost_beacon(outpost_id) do
      :undefined ->
        :error

      pid ->
        try do
          {:ok, OutpostBeacon.snapshot(pid)}
        catch
          :exit, reason -> {:error, reason}
        end
    end
  end

  def local_cluster_snapshot do
    incidents = incident_snapshot()
    queued_repairs = queue_snapshot()

    %{
      node: node(),
      connected_nodes: connected_outposts(),
      incident_total: length(incidents.active_incidents),
      queued_repairs: length(queued_repairs)
    }
  end

  defp producer_stage_name(pipeline_name) do
    # This lesson keeps producer concurrency at 1, so the first Broadway
    # producer process has a stable generated name. A production API would not
    # lean on this internal naming detail so directly.
    Module.concat([pipeline_name, "Broadway", "Producer_0"])
  end

  defp lookup_outpost_beacon(outpost_id) do
    name = {:outpost_beacon, outpost_id}

    case :global.whereis_name(name) do
      :undefined ->
        :ok = :global.sync()
        :global.whereis_name(name)

      pid ->
        pid
    end
  end

  defp ensure_local_outpost_registered(outpost_id) do
    case register_outpost(outpost_id) do
      :yes -> :ok
      :no -> {:error, {:local_registration_failed, :name_taken}}
    end
  end

  defp ensure_remote_outpost_registered(node_name) do
    case :rpc.call(node_name, __MODULE__, :register_outpost, []) do
      :yes -> :ok
      :no -> {:error, {:remote_registration_failed, :name_taken}}
      {:badrpc, reason} -> {:error, {:remote_registration_failed, reason}}
    end
  end
end
