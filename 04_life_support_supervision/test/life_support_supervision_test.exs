defmodule LifeSupportSupervisionTest do
  use ExUnit.Case, async: true

  test "restarts a failed subsystem without taking down its siblings" do
    assert {:ok, _pid} = LifeSupportSupervision.start_habitat("hab-a")

    {:ok, atmosphere_pid} = LifeSupportSupervision.subsystem_pid("hab-a", :atmosphere)
    {:ok, water_pid} = LifeSupportSupervision.subsystem_pid("hab-a", :water)

    assert :ok = LifeSupportSupervision.induce_failure("hab-a", :atmosphere)
    Process.sleep(50)

    {:ok, restarted_atmosphere_pid} = LifeSupportSupervision.subsystem_pid("hab-a", :atmosphere)
    {:ok, current_water_pid} = LifeSupportSupervision.subsystem_pid("hab-a", :water)

    refute restarted_atmosphere_pid == atmosphere_pid
    assert current_water_pid == water_pid
  end
end
