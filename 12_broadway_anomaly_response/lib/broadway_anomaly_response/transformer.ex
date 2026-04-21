defmodule BroadwayAnomalyResponse.Transformer do
  @moduledoc """
  Wraps raw events in `Broadway.Message`.

  Beginner note:
  Broadway processors work with `Broadway.Message`, not plain maps. The
  transformer is the step that adapts the producer's raw event into Broadway's
  message shape.
  """

  def transform(event, _opts) do
    %Broadway.Message{
      data: event,
      # We are not focusing on acknowledgements in this tutorial, so the noop
      # acknowledger keeps the example small.
      acknowledger: Broadway.NoopAcknowledger.init()
    }
  end
end
