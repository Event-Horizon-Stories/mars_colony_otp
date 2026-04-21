defmodule BackpressureAndQueuesTest do
  use ExUnit.Case, async: true

  test "buffers and drains maintenance work while surfacing overload" do
    assert {:ok, false} = BackpressureAndQueues.enqueue_request(%{id: "job-1", system: :water})
    assert {:ok, false} = BackpressureAndQueues.enqueue_request(%{id: "job-2", system: :thermal})
    assert {:ok, true} = BackpressureAndQueues.enqueue_request(%{id: "job-3", system: :airlock})

    assert {:ok, %{id: "job-1"}} = BackpressureAndQueues.dispatch_next()
    assert :ok = BackpressureAndQueues.ack_request("job-1")

    snapshot = BackpressureAndQueues.snapshot()
    assert Enum.map(snapshot.queued, & &1.id) == ["job-2", "job-3"]
    assert snapshot.inflight == %{}
  end
end
