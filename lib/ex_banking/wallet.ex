defmodule ExBanking.Wallet do
  use Agent

  def start_link(_state) do
    {:ok, _} = Registry.start_link(keys: :unique, name: Registry.ViaTest)
  end

  def create(user) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    Agent.start_link(fn -> %{} end, name: name)
    :ok
  end

  def set(user, amount, currency) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    Agent.update( name, fn all -> Map.put(all, currency, amount ) end)
    :ok
  end

  def get(user, currency) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    all = Agent.get(name, & &1)
    case Map.get(all, currency) do
        nil -> 0
        m -> Float.round(m/1, 2)
    end
  end

  def exist?(user) do
    case Registry.lookup(Registry.ViaTest, user) do
      [] -> false
      _ -> true
    end
  end

end