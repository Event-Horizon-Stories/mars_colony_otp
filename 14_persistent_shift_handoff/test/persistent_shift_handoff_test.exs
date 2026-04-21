defmodule PersistentShiftHandoffTest do
  use ExUnit.Case, async: false

  test "restores saved shift context after restart" do
    path = Path.join(System.tmp_dir!(), "mars_colony_shift_handoff_test.bin")
    File.rm(path)

    {:ok, pid} = PersistentShiftHandoff.start_link(path: path)

    assert :ok =
             PersistentShiftHandoff.record_summary(pid, %{
               shift: "night",
               incident: "thermal loop stabilized"
             })

    assert %{summaries: [%{shift: "night"}]} = PersistentShiftHandoff.snapshot(pid)

    stop_supervised_process(pid)

    {:ok, restarted_pid} = PersistentShiftHandoff.start_link(path: path)
    restarted = PersistentShiftHandoff.snapshot(restarted_pid)

    assert restarted.summaries == [%{shift: "night", incident: "thermal loop stabilized"}]
  end

  defp stop_supervised_process(pid) do
    ref = Process.monitor(pid)
    GenServer.stop(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, _reason}
  end
end
