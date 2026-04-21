defmodule ProcessLoopTest do
  use ExUnit.Case, async: true

  test "a spawned habitat loop keeps state between messages" do
    server = ProcessLoop.start(%{habitat: "astra-0", oxygen: 100, water: 100, power: 100})

    assert {:ok, updated} = ProcessLoop.consume_resource(server, :oxygen, 18)
    assert {:ok, _updated} = ProcessLoop.schedule_maintenance(server, "water recycler")
    assert {:ok, status} = ProcessLoop.get_status(server)

    assert updated.oxygen == 82
    assert status.habitat == "astra-0"
    assert status.oxygen == 82
    assert status.maintenance_backlog == ["water recycler"]
    assert List.last(status.status_log) == "maintenance scheduled for water recycler"

    assert :ok = ProcessLoop.stop(server)
  end

  test "the manual protocol uses request refs and ignores unknown messages" do
    server = ProcessLoop.start(%{habitat: "astra-1"})
    send(server, :mystery_message)

    assert {:ok, status} = ProcessLoop.get_status(server)
    assert status.habitat == "astra-1"

    assert :ok = ProcessLoop.stop(server)
    assert {:error, :timeout} = ProcessLoop.get_status(server, 10)
  end
end
