defmodule ExBanking.Supervisor do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [ExBanking.Monitor, ExBanking.Wallet]
    
    Supervisor.init(children, strategy: :one_for_one)
  end
end