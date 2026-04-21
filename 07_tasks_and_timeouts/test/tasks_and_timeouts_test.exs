defmodule TasksAndTimeoutsTest do
  use ExUnit.Case, async: true

  test "returns a route plan from a short-lived task" do
    task =
      TasksAndTimeouts.plan_route_async(%{
        origin: "hab-a",
        destination: "ridge-delta",
        hazard_window: "low radiation"
      })

    result = TasksAndTimeouts.await_plan(task, 50)

    assert result.status == :ready
    assert result.destination == "ridge-delta"
  end

  test "times out when the burst work runs too long" do
    task =
      TasksAndTimeouts.plan_route_async(%{
        origin: "hab-a",
        destination: "weather-tower",
        hazard_window: "dust front",
        latency_ms: 100
      })

    assert catch_exit(TasksAndTimeouts.await_plan(task, 10))
  end
end
