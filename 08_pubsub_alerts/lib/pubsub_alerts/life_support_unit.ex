defmodule PubsubAlerts.LifeSupportUnit do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    habitat_id = Keyword.fetch!(opts, :habitat_id)
    subsystem = Keyword.fetch!(opts, :subsystem)
    name = {:via, Registry, {PubsubAlerts.Registry, {habitat_id, subsystem}}}
    GenServer.start_link(__MODULE__, %{habitat_id: habitat_id, subsystem: subsystem}, name: name)
  end

  def induce_failure(server), do: GenServer.call(server, :induce_failure)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:induce_failure, _from, state) do
    {:stop, {:shutdown, :simulated_failure}, :ok, state}
  end
end
