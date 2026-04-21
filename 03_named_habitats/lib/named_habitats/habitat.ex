defmodule NamedHabitats.Habitat do
  @moduledoc """
  A habitat server that can be looked up later through `Registry`.

  This server is intentionally simple. The new lesson here is not extra habitat
  behavior. The lesson is that multiple instances of the *same* module can be
  running at once and still be addressed by a stable ID.
  """

  use GenServer

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)

    # `:via` tells the GenServer to register itself through `Registry`.
    # That gives us "find habitat by ID later" instead of "hope someone kept the PID."
    name = {:via, Registry, {NamedHabitats.Registry, id}}
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def get_status(server), do: GenServer.call(server, :get_status)

  @impl true
  def init(opts) do
    {:ok,
     %{
       id: Keyword.fetch!(opts, :id),
       oxygen: Keyword.get(opts, :oxygen, 100),
       water: Keyword.get(opts, :water, 100),
       power: Keyword.get(opts, :power, 100)
     }}
  end

  # This stays intentionally boring so the focus remains on identity and lookup.
  @impl true
  def handle_call(:get_status, _from, state), do: {:reply, state, state}
end
