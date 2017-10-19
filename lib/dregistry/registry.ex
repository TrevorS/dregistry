defmodule Dregistry.Registry do
  @table_name :d_registry

  def new do
    :ets.new(@table_name, [:named_table])
  end

  def lookup(module, id) do
    case :ets.lookup(@table_name, {module, id}) do
      [{{^module, ^id}, pid}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def insert(module, id, pid) do
    :ets.insert(@table_name, {{module, id}, pid})
  end

  def remove(module, id) do
    :ets.delete(@table_name, {module, id})
  end

  def remove_by_pid(pid) do
    :ets.match_delete(@table_name, {:"_", pid})
  end
end
