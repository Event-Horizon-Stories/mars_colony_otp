defmodule DistributedOutpostsTest do
  use ExUnit.Case, async: false

  setup_all do
    ensure_distributed_node!()
    :ok
  end

  setup do
    {:ok, peer, remote_node} =
      :peer.start_link(%{
        name: :outpost_alpha,
        args: peer_args()
      })

    assert {:ok, _started} =
             :rpc.call(remote_node, :application, :ensure_all_started, [:distributed_outposts])

    on_exit(fn ->
      try do
        if Process.alive?(peer) do
          :peer.stop(peer)
        end
      catch
        :exit, _reason -> :ok
      end
    end)

    %{remote_node: remote_node}
  end

  test "connects to a remote outpost and queries its runtime state", %{remote_node: remote_node} do
    assert DistributedOutposts.connect_outpost(remote_node)

    assert {:ok, _pid} =
             :rpc.call(remote_node, DistributedOutposts, :start_habitat, ["outpost-a"])

    assert :ok =
             :rpc.call(remote_node, DistributedOutposts, :report_alert, [
               %{habitat: "outpost-a", system: :thermal, severity: :critical}
             ])

    Process.sleep(50)

    incident_snapshot = DistributedOutposts.remote_incident_snapshot(remote_node)
    queue_snapshot = DistributedOutposts.remote_queue_snapshot(remote_node)

    assert [%{system: :thermal, severity: :critical}] = incident_snapshot.active_incidents

    assert [%{id: "repair-thermal", system: :thermal, action: "dispatch repair crew"}] =
             queue_snapshot
  end

  test "discovers a remote outpost through a global beacon", %{remote_node: remote_node} do
    assert DistributedOutposts.connect_outpost(remote_node)

    assert :ok =
             :rpc.call(remote_node, DistributedOutposts, :enqueue_request, [
               %{id: "repair-water", system: :water, action: "replace pump seal"}
             ])

    assert :ok =
             :rpc.call(remote_node, DistributedOutposts, :report_alert, [
               %{habitat: "outpost-a", system: :water, severity: :critical}
             ])

    Process.sleep(50)

    assert {:ok, snapshot} = DistributedOutposts.outpost_snapshot(remote_node)
    assert snapshot.node == remote_node
    assert snapshot.incident_total == 1
    assert snapshot.queued_repairs == 2
    assert node() in snapshot.connected_nodes
  end

  test "returns an error instead of crashing when a discovered beacon is not callable" do
    assert :yes = :global.register_name({:outpost_beacon, :stale_demo}, self())
    assert {:error, _reason} = DistributedOutposts.outpost_snapshot(:stale_demo)
    :global.unregister_name({:outpost_beacon, :stale_demo})
  end

  test "returns a structured error when local beacon registration is already taken", %{
    remote_node: remote_node
  } do
    :global.unregister_name({:outpost_beacon, node()})
    assert :yes = :global.register_name({:outpost_beacon, node()}, self())

    assert {:error, {:local_registration_failed, :name_taken}} =
             DistributedOutposts.connect_outpost(remote_node)

    :global.unregister_name({:outpost_beacon, node()})
    assert :yes = DistributedOutposts.register_outpost()
  end

  defp ensure_distributed_node! do
    case Node.alive?() do
      true ->
        :ok

      false ->
        # `epmd` must be running before the local test VM can become a distributed node.
        {_, 0} = System.cmd("epmd", ["-daemon"])
        unique_name = :"mission_control_#{System.unique_integer([:positive])}"
        {:ok, _pid} = :net_kernel.start([unique_name, :shortnames])
        # Every node in the lesson uses the same cookie so they can establish trust.
        true = Node.set_cookie(:mars_colony_cookie)
        :ok
    end
  end

  defp peer_args do
    # The peer needs the lesson and dependency beam files on its code path or
    # `:application.ensure_all_started/1` cannot find the tutorial app.
    code_path_args =
      :code.get_path()
      |> Enum.flat_map(fn path -> [~c"-pa", path] end)

    [~c"-setcookie", Atom.to_charlist(Node.get_cookie()) | code_path_args]
  end
end
