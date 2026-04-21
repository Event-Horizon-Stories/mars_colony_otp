defmodule DistributedOutposts.HandoffLog do
  @moduledoc """
  Stores shift summaries that should survive a restart.

  this is intentionally narrow persistence. The tutorial is not trying to
  persist the whole colony. It only persists the handoff summaries that are
  useful to the next shift.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def record_summary(server, summary), do: GenServer.call(server, {:record_summary, summary})
  def snapshot(server), do: GenServer.call(server, :snapshot)

  @impl true
  def init(opts) do
    path = Keyword.fetch!(opts, :path)

    # Load previous summaries if they already exist on disk.
    {:ok, load_state(path)}
  end

  @impl true
  def handle_call({:record_summary, summary}, _from, state) do
    next_state = %{state | summaries: state.summaries ++ [summary]}

    # Persist immediately so the handoff survives a process restart.
    persist!(next_state)
    {:reply, :ok, next_state}
  end

  def handle_call(:snapshot, _from, state), do: {:reply, state, state}

  defp load_state(path) do
    with {:ok, binary} <- File.read(path),
         {:ok, persisted_state} <- decode_state(binary) do
      # Put the file path back into the loaded state because we do not store it on disk.
      Map.put(persisted_state, :path, path)
    else
      # First boot or an unreadable file: start with an empty handoff history.
      {:error, _reason} -> empty_state(path)
    end
  end

  defp persist!(state) do
    # Do not persist the file path itself; it is runtime-specific.
    persisted = Map.delete(state, :path)
    File.write!(state.path, :erlang.term_to_binary(persisted))
  end

  defp decode_state(binary) do
    try do
      {:ok, :erlang.binary_to_term(binary, [:safe])}
    rescue
      ArgumentError -> {:error, :invalid_term}
    end
  end

  defp empty_state(path), do: %{path: path, summaries: []}
end
