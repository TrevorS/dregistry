defmodule Dregistry do
  use GenServer

  alias Dregistry.Registry
  alias Dregistry.ProcessHandler

  @server_name :dregistry

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @server_name)
  end

  @spec lookup(term, term) :: {:ok, pid} | {:error, :not_found}
  def lookup(module, id) do
    Registry.lookup(module, id)
  end

  @spec lookup_or_start(pid, term, list) :: {:ok, pid} | {:error, term}
  def lookup_or_start(module, id, args \\ []) do
    GenServer.call(@server_name, {:lookup_or_start, module, id, args})
  end

  @spec stop(pid, term) :: :ok | {:error, :not_found}
  def stop(module, id) do
    GenServer.call(@server_name, {:stop, module, id})
  end

  # Server

  def init(_) do
    Process.flag(:trap_exit, true)

    Registry.new()

    {:ok, nil}
  end

  def handle_call({:lookup_or_start, module, id, args}, _from, state) do
    result =
      case lookup(module, id) do
        {:error, :not_found} -> ProcessHandler.start(module, args)
        {:ok, pid} -> {:ok, pid}
      end

    msg =
      case result do
        {:ok, pid} ->
          {:ok, pid}
        {:started, pid} ->
          Registry.insert(module, id, pid)
          {:ok, pid}
        error ->
          error
      end

    {:reply, msg, state}
  end

  def handle_call({:stop, module, id}, _from, state) do
    {:ok, pid} = lookup(module, id)

    msg = case pid do
      nil ->
        {:error, :not_found}
      pid ->
        ProcessHandler.stop(pid)

        Registry.remove(module, id)

        :ok
    end

    {:reply, msg, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    Registry.remove_by_pid(pid)

    {:noreply, state}
  end
end
