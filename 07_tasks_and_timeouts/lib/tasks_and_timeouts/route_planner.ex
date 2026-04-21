defmodule TasksAndTimeouts.RoutePlanner do
  @moduledoc false

  def plan_route_async(route_request) do
    Task.Supervisor.async_nolink(TasksAndTimeouts.TaskSupervisor, fn ->
      maybe_sleep(Map.get(route_request, :latency_ms, 0))

      %{
        origin: route_request.origin,
        destination: route_request.destination,
        hazard_window: route_request.hazard_window,
        status: :ready
      }
    end)
  end

  def await_plan(task, timeout) do
    Task.await(task, timeout)
  end

  defp maybe_sleep(duration) when duration > 0, do: Process.sleep(duration)
  defp maybe_sleep(_duration), do: :ok
end
