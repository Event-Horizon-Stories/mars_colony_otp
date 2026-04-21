defmodule IncidentCommander.Transformer do
  @moduledoc false

  def transform(event, _opts) do
    %Broadway.Message{
      data: event,
      acknowledger: Broadway.NoopAcknowledger.init()
    }
  end
end
