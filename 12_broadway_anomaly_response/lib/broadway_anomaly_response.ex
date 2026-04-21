defmodule BroadwayAnomalyResponse do
  @moduledoc """
  Public API for the Broadway lesson.
  """

  def start_pipeline(opts) do
    notify = Keyword.fetch!(opts, :notify)
    pipeline_name = Keyword.get(opts, :name, BroadwayAnomalyResponse.Pipeline)

    BroadwayAnomalyResponse.Pipeline.start_link(
      name: pipeline_name,
      notify: notify
    )
  end

  def push_event(event, pipeline_name \\ BroadwayAnomalyResponse.Pipeline) do
    BroadwayAnomalyResponse.Producer.push_event(producer_stage_name(pipeline_name), event)
  end

  defp producer_stage_name(pipeline_name) do
    Module.concat([pipeline_name, "Broadway", "Producer_0"])
  end
end
