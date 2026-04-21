defmodule PersistentShiftHandoff do
  @moduledoc """
  Public API for the persistence lesson.
  """

  defdelegate start_link(opts), to: PersistentShiftHandoff.HandoffLog
  defdelegate record_summary(server, summary), to: PersistentShiftHandoff.HandoffLog
  defdelegate snapshot(server), to: PersistentShiftHandoff.HandoffLog
end
