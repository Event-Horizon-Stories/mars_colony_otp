defmodule NamedHabitats.Habitat do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)
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

  @impl true
  def handle_call(:get_status, _from, state), do: {:reply, state, state}
end
