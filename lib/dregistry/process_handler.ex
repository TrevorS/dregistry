defmodule Dregistry.ProcessHandler do
  def start(module, args) do
    case apply(module, :start_link, args) do
      {:ok, pid} -> {:started, pid}
      error -> error
    end
  end

  def stop(pid) do
    GenServer.stop(pid)

    pid
  end
end
