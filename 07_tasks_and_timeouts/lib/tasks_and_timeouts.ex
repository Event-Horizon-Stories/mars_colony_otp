defmodule TasksAndTimeouts do
  @moduledoc """
  Public API for bursty task work.
  """

  alias TasksAndTimeouts.RoutePlanner

  defdelegate plan_route_async(route_request), to: RoutePlanner
  defdelegate await_plan(task, timeout), to: RoutePlanner
end
