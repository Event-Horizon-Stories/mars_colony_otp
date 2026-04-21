defmodule HabitatBootstrap.HabitatTest do
  use ExUnit.Case, async: true

  alias HabitatBootstrap.Habitat

  test "tracks pure resource changes and maintenance decisions" do
    habitat =
      "Astra-1"
      |> Habitat.new(crew_count: 6)
      |> Habitat.consume_resource(:oxygen, 18)
      |> Habitat.consume_resource(:water, 12)
      |> Habitat.schedule_maintenance("water recycler")

    assert habitat.oxygen == 82
    assert habitat.water == 88
    assert habitat.crew_count == 6
    assert habitat.maintenance_backlog == ["water recycler"]
    assert Enum.at(habitat.status_log, 0) == "oxygen adjusted to 82"
    assert List.last(habitat.status_log) == "maintenance scheduled for water recycler"
  end

  test "records when a resource crosses the safety threshold" do
    habitat =
      Habitat.new("Astra-2")
      |> Habitat.consume_resource(:power, 80)

    assert habitat.power == 20
    assert "power is now below the safety threshold" in habitat.status_log
  end
end
