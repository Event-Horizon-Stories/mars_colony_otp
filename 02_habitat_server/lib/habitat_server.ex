defmodule HabitatServer do
  @moduledoc """
  Public API for the live habitat lesson.
  """

  alias HabitatServer.Habitat

  defdelegate start_link(opts), to: Habitat
  defdelegate get_status(server), to: Habitat
  defdelegate consume_resource(server, resource, amount), to: Habitat
  defdelegate set_crew_count(server, crew_count), to: Habitat
  defdelegate schedule_maintenance(server, system), to: Habitat
end
