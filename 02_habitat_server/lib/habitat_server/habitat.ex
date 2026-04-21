defmodule HabitatServer.Habitat do
  @moduledoc """
  A single habitat implemented as a `GenServer`.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))
  end

  def get_status(server), do: GenServer.call(server, :get_status)

  def consume_resource(server, resource, amount),
    do: GenServer.call(server, {:consume_resource, resource, amount})

  def schedule_maintenance(server, system),
    do: GenServer.cast(server, {:schedule_maintenance, system})

  @impl true
  def init(opts) do
    {:ok,
     %{
       name: Keyword.fetch!(opts, :habitat_name),
       oxygen: Keyword.get(opts, :oxygen, 100),
       water: Keyword.get(opts, :water, 100),
       power: Keyword.get(opts, :power, 100),
       maintenance_backlog: [],
       status_log: []
     }}
  end

  @impl true
  def handle_call(:get_status, _from, state), do: {:reply, state, state}

  def handle_call({:consume_resource, resource, amount}, _from, state)
      when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 do
    updated = max(Map.fetch!(state, resource) - amount, 0)

    next_state =
      state |> Map.put(resource, updated) |> append_status("#{resource} adjusted to #{updated}")

    {:reply, next_state, next_state}
  end

  @impl true
  def handle_cast({:schedule_maintenance, system}, state) do
    next_state =
      state
      |> Map.update!(:maintenance_backlog, &(&1 ++ [system]))
      |> append_status("maintenance scheduled for #{system}")

    {:noreply, next_state}
  end

  defp append_status(state, entry) do
    Map.update!(state, :status_log, &(&1 ++ [entry]))
  end
end
