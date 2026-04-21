defmodule LifeSupportSupervision.LifeSupportUnit do
  @moduledoc """
  One life-support subsystem inside a habitat.

  This process is intentionally tiny because the lesson is about restart
  isolation. It only needs enough behavior to show that one child can crash and
  be restarted without taking siblings down.
  """

  use GenServer

  def start_link(opts) do
    habitat_id = Keyword.fetch!(opts, :habitat_id)
    subsystem = Keyword.fetch!(opts, :subsystem)

    # Register by `{habitat_id, subsystem}` so operators can look up exactly the
    # process they want to inspect or crash for the lesson.
    name = {:via, Registry, {LifeSupportSupervision.Registry, {habitat_id, subsystem}}}
    GenServer.start_link(__MODULE__, %{habitat_id: habitat_id, subsystem: subsystem}, name: name)
  end

  def induce_failure(server), do: GenServer.call(server, :induce_failure)

  # Keep the state minimal so the supervision behavior stays easy to see.
  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:induce_failure, _from, state) do
    # Stopping the process here lets the parent supervisor demonstrate restart behavior.
    {:stop, {:shutdown, :simulated_failure}, :ok, state}
  end
end
