defmodule DistributedOutposts.Pipeline do
  @moduledoc false

  use Broadway

  def start_link(opts) do
    notify = Keyword.fetch!(opts, :notify)
    broadway_name = Keyword.fetch!(opts, :name)

    Broadway.start_link(__MODULE__,
      name: broadway_name,
      context: %{notify: notify},
      producer: [
        module: {DistributedOutposts.Producer, []},
        transformer: {DistributedOutposts.Transformer, :transform, []},
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
    |> Broadway.Message.put_batcher(batcher)
    |> Broadway.Message.update_data(fn payload -> Map.put(payload, :classified, true) end)
  end

  @impl true
  def handle_batch(:critical, messages, _batch_info, context) do
    ids = Enum.map(messages, & &1.data.id)
    send(context.notify, {:critical_batch, ids})
    messages
  end

  def handle_batch(_batcher, messages, _batch_info, _context), do: messages
end
