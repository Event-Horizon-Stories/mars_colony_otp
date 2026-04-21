defmodule DynamicRoversTest do
  use ExUnit.Case, async: true

  test "launches, addresses, and retires rovers at runtime" do
    assert {:ok, _pid} = DynamicRovers.launch_rover("rov-7", battery: 84)
    assert {:ok, _state} = DynamicRovers.assign_mission("rov-7", "survey ridge delta")

    assert {:ok, rover} = DynamicRovers.rover_status("rov-7")
    assert rover.status == :deployed
    assert rover.mission == "survey ridge delta"
    assert rover.battery == 84

    assert :ok = DynamicRovers.retire_rover("rov-7")
    assert :error = DynamicRovers.lookup_rover("rov-7")
  end
end
