defmodule BroadwayAnomalyResponse.Pipeline do
  @moduledoc """
  The Broadway pipeline for anomaly processing.

  Broadway gives a higher-level shape to the same streaming problem introduced
  with `GenStage`: where events come from, how many processors exist, and which
  events should be batched together.
  """

  use Broadway

  def start_link(opts) do
    notify = Keyword.fetch!(opts, :notify)
    broadway_name = Keyword.fetch!(opts, :name)

    Broadway.start_link(__MODULE__,
      name: broadway_name,
      context: %{notify: notify},
      producer: [
        module: {BroadwayAnomalyResponse.Producer, []},
        transformer: {BroadwayAnomalyResponse.Transformer, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        critical: [concurrency: 1, batch_size: 2, batch_timeout: 50]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    data = message.data
    batcher = if data.severity == :critical, do: :critical, else: :default

    message
    # Route critical events into a special batcher so they can be grouped later.
    |> Broadway.Message.put_batcher(batcher)
    # Mark the payload so downstream code can tell it passed through classification.
    |> Broadway.Message.update_data(fn payload -> Map.put(payload, :classified, true) end)
  end

  @impl true
  def handle_batch(:critical, messages, _batch_info, context) do
    ids = Enum.map(messages, & &1.data.id)

    # In this lesson, the "side effect" of the batch is notifying the test or caller.
    send(context.notify, {:critical_batch, ids})
    messages
  end

  def handle_batch(_batcher, messages, _batch_info, _context), do: messages
end
