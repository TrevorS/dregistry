defmodule Dregistry.Worker do
  use GenServer

  def start_link(counter, opts \\ []) do
    GenServer.start_link(__MODULE__, counter, opts)
  end

  def init(counter) do
    {:ok, counter}
  end

  def increment(pid, incr) do
    GenServer.call(pid, {:increment, incr})
  end

  def handle_call({:increment, incr}, _from, counter) do
    counter = counter + incr
    {:reply, counter, counter}
  end
end
