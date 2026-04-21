defmodule HabitatBootstrap.Habitat do
  @moduledoc """
  Pure state transitions for a single habitat.
  """

  @enforce_keys [:name]
  defstruct name: nil,
            crew_count: 4,
            oxygen: 100,
            water: 100,
            power: 100,
            maintenance_backlog: [],
            status_log: []

  def new(name, opts \\ []) when is_binary(name) do
    struct!(__MODULE__, Keyword.merge([name: name], opts))
  end

  def consume_resource(%__MODULE__{} = habitat, resource, amount)
      when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 do
    current = Map.fetch!(habitat, resource)
    updated = max(current - amount, 0)

    habitat
    |> Map.put(resource, updated)
    |> add_status("#{resource} adjusted to #{updated}")
    |> maybe_add_low_resource_status(resource, updated)
  end

  def schedule_maintenance(%__MODULE__{} = habitat, system) when is_binary(system) do
    %{habitat | maintenance_backlog: habitat.maintenance_backlog ++ [system]}
    |> add_status("maintenance scheduled for #{system}")
  end

  def set_crew_count(%__MODULE__{} = habitat, crew_count)
      when is_integer(crew_count) and crew_count > 0 do
    %{habitat | crew_count: crew_count}
    |> add_status("crew count set to #{crew_count}")
  end

  defp maybe_add_low_resource_status(habitat, resource, value) when value <= 25 do
    add_status(habitat, "#{resource} is now below the safety threshold")
  end

  defp maybe_add_low_resource_status(habitat, _resource, _value), do: habitat

  defp add_status(habitat, entry) do
    %{habitat | status_log: habitat.status_log ++ [entry]}
  end
end
