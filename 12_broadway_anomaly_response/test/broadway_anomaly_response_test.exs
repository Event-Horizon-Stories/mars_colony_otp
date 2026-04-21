defmodule BroadwayAnomalyResponseTest do
  use ExUnit.Case, async: false

  test "batches critical anomaly events through Broadway" do
    assert {:ok, _pid} = BroadwayAnomalyResponse.start_pipeline(notify: self())

    assert :ok =
             BroadwayAnomalyResponse.push_event(%{
               id: "evt-1",
               severity: :critical,
               source: :thermal
             })

    assert :ok =
             BroadwayAnomalyResponse.push_event(%{
               id: "evt-2",
               severity: :critical,
               source: :pressure
             })

    assert_receive {:critical_batch, ["evt-1", "evt-2"]}
  end
end
