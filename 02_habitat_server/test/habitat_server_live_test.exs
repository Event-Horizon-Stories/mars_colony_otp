defmodule HabitatServerLiveTest do
  use ExUnit.Case, async: true

  alias HabitatServer.Habitat

  test "handles synchronous resource updates and async maintenance events" do
    {:ok, pid} = Habitat.start_link(habitat_name: "Astra-1")

    updated = Habitat.consume_resource(pid, :oxygen, 10)
    assert updated.oxygen == 90

    Habitat.schedule_maintenance(pid, "thermal scrubber")
    Process.sleep(20)

    status = Habitat.get_status(pid)
    assert status.maintenance_backlog == ["thermal scrubber"]
    assert List.last(status.status_log) == "maintenance scheduled for thermal scrubber"
  end
end
