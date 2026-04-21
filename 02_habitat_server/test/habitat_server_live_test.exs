defmodule HabitatServerLiveTest do
  use ExUnit.Case, async: true

  alias HabitatServer.Habitat

  test "keeps lesson 1 habitat behavior inside a live process" do
    {:ok, pid} = Habitat.start_link(habitat_name: "Astra-1")

    updated = Habitat.consume_resource(pid, :oxygen, 80)
    assert updated.oxygen == 20
    assert "oxygen is now below the safety threshold" in updated.status_log

    updated = Habitat.set_crew_count(pid, 6)
    assert updated.crew_count == 6

    Habitat.schedule_maintenance(pid, "thermal scrubber")

    status =
      wait_for_status(
        fn status ->
          status.maintenance_backlog == ["thermal scrubber"] &&
            List.last(status.status_log) == "maintenance scheduled for thermal scrubber"
        end,
        pid
      )

    assert status.maintenance_backlog == ["thermal scrubber"]
    assert List.last(status.status_log) == "maintenance scheduled for thermal scrubber"
  end

  defp wait_for_status(predicate, pid) do
    Enum.reduce_while(1..20, nil, fn _, _acc ->
      status = Habitat.get_status(pid)

      if predicate.(status) do
        {:halt, status}
      else
        Process.sleep(10)
        {:cont, nil}
      end
    end)
  end
end
