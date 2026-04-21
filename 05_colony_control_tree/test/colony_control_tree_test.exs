defmodule ColonyControlTreeTest do
  use ExUnit.Case, async: true

  alias ColonyControlTree.DomainService

  test "boots top-level services and keeps sibling branches isolated" do
    assert {:ok, mission_control_pid} = ColonyControlTree.service_pid(:mission_control)
    assert {:ok, comms_pid} = ColonyControlTree.service_pid(:comms_relay)
    assert {:ok, storage_pid} = ColonyControlTree.service_pid(:storage)

    assert %{status: :online} = DomainService.snapshot(mission_control_pid)
    assert %{status: :online} = DomainService.snapshot(storage_pid)

    assert :ok = DomainService.induce_failure(comms_pid)
    Process.sleep(50)

    assert {:ok, restarted_comms_pid} = ColonyControlTree.service_pid(:comms_relay)
    refute restarted_comms_pid == comms_pid
    assert DomainService.snapshot(mission_control_pid).status == :online
    assert DomainService.snapshot(storage_pid).status == :online
  end
end
