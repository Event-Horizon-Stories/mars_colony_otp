defmodule ProcessLoop.HabitatLoop do
  @moduledoc """
  A manually implemented process loop for one habitat.

  The process is started with `spawn_link/1`, then stays alive by calling
  `loop/1` recursively after each message it handles. This is the raw shape
  behind many OTP abstractions: a process with state, a mailbox, and a protocol.
  """

  def start(initial_state \\ %{}) do
    spawn_link(fn -> loop(normalize_state(initial_state)) end)
  end

  defp loop(state) do
    receive do
      {:get_status, caller, ref} ->
        send(caller, {ref, {:ok, state}})
        loop(state)

      {{:consume_resource, resource, amount}, caller, ref}
      when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 ->
        next_state =
          state
          |> Map.update!(resource, &max(&1 - amount, 0))
          |> append_status(
            "#{resource} adjusted to #{(Map.fetch!(state, resource) - amount) |> max(0)}"
          )

        send(caller, {ref, {:ok, next_state}})
        loop(next_state)

      {{:schedule_maintenance, system}, caller, ref} when is_binary(system) ->
        next_state =
          state
          |> Map.update!(:maintenance_backlog, &(&1 ++ [system]))
          |> append_status("maintenance scheduled for #{system}")

        send(caller, {ref, {:ok, next_state}})
        loop(next_state)

      {:stop, caller, ref} ->
        send(caller, {ref, :ok})
        :ok

      _unknown_message ->
        # Ignore unexpected messages and keep waiting.
        loop(state)
    end
  end

  defp normalize_state(initial_state) do
    %{
      habitat: Map.get(initial_state, :habitat, "hab-a"),
      oxygen: Map.get(initial_state, :oxygen, 100),
      water: Map.get(initial_state, :water, 100),
      power: Map.get(initial_state, :power, 100),
      maintenance_backlog: Map.get(initial_state, :maintenance_backlog, []),
      status_log: Map.get(initial_state, :status_log, [])
    }
  end

  defp append_status(state, entry) do
    Map.update!(state, :status_log, &(&1 ++ [entry]))
  end
end
