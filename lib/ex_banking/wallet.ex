defmodule ExBanking.Wallet do

  def start_link do
    {:ok, _} = Registry.start_link(keys: :unique, name: Registry.ViaTest)
  end

  def init(user) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    Agent.start_link(fn -> %{} end, name: name)
    :ok
  end

  def set(user, amount, currency) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    Agent.update( name, &( Map.put(&1, currency, amount )) )
    :ok
  end

  def get(user, currency) do
    name = {:via, Registry, {Registry.ViaTest, user}}
    all = Agent.get(name, & &1)
    case Map.get(all, currency) do
        nil -> 0
        m -> m
    end
  end

  def exist?(user) do
    case Registry.lookup(Registry.ViaTest, user) do
      [] -> false
      _ -> true
    end
  end

end