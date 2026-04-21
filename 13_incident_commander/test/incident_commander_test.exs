defmodule IncidentCommanderTest do
  use ExUnit.Case, async: false

  test "turns a critical alert into coordinated response state" do
    IncidentCommander.report_alert(%{
      system: :thermal_loop,
      severity: :critical,
      habitat_id: "hab-a"
    })

    Process.sleep(50)

    snapshot = IncidentCommander.incident_snapshot()
    queue = IncidentCommander.queue_snapshot()

    assert [%{system: :thermal_loop}] = snapshot.active_incidents
    assert ["reroute load and dispatch thermal_loop repair"] = snapshot.response_log
    assert [%{system: :thermal_loop, action: "dispatch repair crew"}] = queue
  end
end
