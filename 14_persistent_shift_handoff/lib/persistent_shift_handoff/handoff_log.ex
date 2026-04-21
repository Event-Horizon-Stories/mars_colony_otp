defmodule PersistentShiftHandoff.HandoffLog do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def record_summary(server, summary), do: GenServer.call(server, {:record_summary, summary})
  def snapshot(server), do: GenServer.call(server, :snapshot)

  @impl true
  def init(opts) do
    path = Keyword.fetch!(opts, :path)
    {:ok, load_state(path)}
  end

  @impl true
  def handle_call({:record_summary, summary}, _from, state) do
    next_state = %{state | summaries: state.summaries ++ [summary]}
    persist!(next_state)
    {:reply, :ok, next_state}
  end

  def handle_call(:snapshot, _from, state), do: {:reply, state, state}

  defp load_state(path) do
    case File.read(path) do
      {:ok, binary} ->
        Map.put(:erlang.binary_to_term(binary), :path, path)

      {:error, :enoent} ->
        %{path: path, summaries: []}
    end
  end

  defp persist!(state) do
    persisted = Map.delete(state, :path)
    File.write!(state.path, :erlang.term_to_binary(persisted))
  end
end
