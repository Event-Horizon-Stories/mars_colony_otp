defmodule GenstageResourcePipelineTest do
  use ExUnit.Case, async: false

  test "flows sensor packets through normalization and anomaly detection" do
    assert {:ok, _pipeline} = GenstageResourcePipeline.start_pipeline(notify: self())

    assert :ok =
             GenstageResourcePipeline.publish_sensor_packet(%{
               sensor_id: "thermal-7",
               temperature_f: 158.0
             })

    assert_receive {:anomaly_detected, %{sensor_id: "thermal-7", temperature_c: 70.0}}
  end
end
