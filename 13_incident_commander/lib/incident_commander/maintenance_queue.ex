defmodule IncidentCommander.MaintenanceQueue do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enqueue(action), do: GenServer.call(__MODULE__, {:enqueue, action})
  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(_opts), do: {:ok, []}

  @impl true
  def handle_call({:enqueue, action}, _from, state), do: {:reply, :ok, state ++ [action]}
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}
end
