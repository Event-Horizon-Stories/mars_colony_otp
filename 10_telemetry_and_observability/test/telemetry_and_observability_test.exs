defmodule TelemetryAndObservabilityTest do
  use ExUnit.Case, async: false

  test "emits telemetry on enqueue and dispatch" do
    test_pid = self()
    handler_id = "queue-events-#{System.unique_integer([:positive])}"

    :telemetry.attach_many(
      handler_id,
      [
        [:mars_colony, :maintenance_queue, :enqueue],
        [:mars_colony, :maintenance_queue, :dispatch]
      ],
      fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry_event, event, measurements, metadata})
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    assert :ok = TelemetryAndObservability.enqueue_request(%{id: "job-1", system: :power})
    assert {:ok, %{id: "job-1"}} = TelemetryAndObservability.dispatch_next()

    assert_receive {:telemetry_event, [:mars_colony, :maintenance_queue, :enqueue],
                    %{queue_depth: 1}, %{request_id: "job-1", overloaded?: false}}

    assert_receive {:telemetry_event, [:mars_colony, :maintenance_queue, :dispatch],
                    %{queue_depth: 0}, %{request_id: "job-1"}}
  end
end
