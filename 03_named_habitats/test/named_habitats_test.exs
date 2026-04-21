defmodule NamedHabitatsTest do
  use ExUnit.Case, async: true

  test "starts multiple habitats that can be addressed by id" do
    assert {:ok, _pid} = NamedHabitats.start_habitat("hab-a", oxygen: 91)
    assert {:ok, _pid} = NamedHabitats.start_habitat("lab-1", water: 83)

    assert {:ok, hab_a} = NamedHabitats.get_status("hab-a")
    assert {:ok, lab_1} = NamedHabitats.get_status("lab-1")

    assert hab_a.oxygen == 91
    assert hab_a.id == "hab-a"
    assert lab_1.water == 83
    assert lab_1.id == "lab-1"
  end
end
