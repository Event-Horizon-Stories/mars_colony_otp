defmodule ColonyControlTree do
  @moduledoc """
  Public API for the colony-wide supervision tree lesson.
  """

  def service_pid(service) do
    case Registry.lookup(ColonyControlTree.Registry, service) do
      [{pid, _value}] -> {:ok, pid}
      [] -> :error
    end
  end
end
