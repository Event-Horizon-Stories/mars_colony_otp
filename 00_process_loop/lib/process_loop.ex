defmodule ProcessLoop do
  @moduledoc """
  Public API for the raw process-loop prelude.

  This lesson is deliberately small and slightly awkward. The goal is to show
  the manual process protocol that `GenServer` will later formalize.
  """

  alias ProcessLoop.HabitatLoop

  def start(initial_state \\ %{}) do
    HabitatLoop.start(initial_state)
  end

  def get_status(server, timeout \\ 100) do
    request(server, :get_status, timeout)
  end

  def consume_resource(server, resource, amount, timeout \\ 100) do
    request(server, {:consume_resource, resource, amount}, timeout)
  end

  def schedule_maintenance(server, system, timeout \\ 100) do
    request(server, {:schedule_maintenance, system}, timeout)
  end

  def stop(server, timeout \\ 100) do
    request(server, :stop, timeout)
  end

  defp request(server, message, timeout) do
    ref = make_ref()

    send(server, {message, self(), ref})

    receive do
      {^ref, reply} -> reply
    after
      timeout -> {:error, :timeout}
    end
  end
end
