defmodule PubsubAlertsTest do
  use ExUnit.Case, async: true

  test "fans one alert out to multiple subscribers" do
    parent = self()
    PubsubAlerts.subscribe(:critical_alerts)

    spawn_link(fn ->
      PubsubAlerts.subscribe(:critical_alerts)
      send(parent, :subscribed)

      receive do
        {:colony_alert, :critical_alerts, payload} ->
          send(parent, {:forwarded, payload})
      end
    end)

    assert_receive :subscribed
    PubsubAlerts.publish(:critical_alerts, %{system: :thermal, status: :critical})

    assert_receive {:colony_alert, :critical_alerts, %{system: :thermal, status: :critical}}
    assert_receive {:forwarded, %{system: :thermal, status: :critical}}
  end
end
