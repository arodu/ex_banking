defmodule ExBanking.Monitor do

  use GenServer
  alias ExBanking.Users

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  def init_process(bucket, user) do
    GenServer.cast(bucket, {:inc, user})
  end

  @impl true
  def handle_cast({:inc, user}, state) do
    state = counter(:inc, state, user)
    {:noreply, state}
  end

  def create(bucket, user) do
    GenServer.call(bucket, {:create, user})
  end

  @impl true
  def handle_call({:create, user}, _from, state) do
    out = Users.create(user)
    {:reply, out, state}
  end

  def deposit(bucket, user, amount, currency) do
    GenServer.call(bucket, {:deposit, user, amount, currency})
  end

  @impl true
  def handle_call({:deposit, user, amount, currency}, _from, state) do
    new_state = counter(:dec, state, user)
    cond do
      counter(:get, state, user)<10 ->
        out = Users.deposit(user, amount, currency)
        {:reply, out, new_state}                

      true -> 
        {:reply, {:error, :too_many_requests_to_user}, new_state}    
    end
  end

  def withdraw(bucket, user, amount, currency) do
    GenServer.call(bucket, {:withdraw, user, amount, currency})
  end

  @impl true
  def handle_call({:withdraw, user, amount, currency}, _from, state) do
    new_state = counter(:dec, state, user)
    cond do
      counter(:get, state, user)<10 ->
        out = Users.withdraw(user, amount, currency)
        {:reply, out, new_state}                

      true -> 
        {:reply, {:error, :too_many_requests_to_user}, new_state}    
    end
  end

  def get_balance(bucket, user, currency) do
    GenServer.call(bucket, {:balance, user, currency})
  end

  @impl true
  def handle_call({:balance, user, currency}, _from, state) do
    new_state = counter(:dec, state, user)
    cond do
      counter(:get, state, user)<10 ->
        out = Users.get_balance(user, currency)
        {:reply, out, new_state}

      true -> 
        {:reply, {:error, :too_many_requests_to_user}, new_state}    
    end
  end

  def send(bucket, from_user, to_user, amount, currency) do
    GenServer.call(bucket, {:send, from_user, to_user, amount, currency})
  end

  @impl true
  def handle_call({:send, from_user, to_user, amount, currency}, _from, state) do

    out = cond do
      counter(:get, state, from_user)>10 ->
        {:error, :too_many_requests_to_sender}

      counter(:get, state, to_user)>10 ->
        {:error, :too_many_requests_to_receiver}

      true -> 
        Users.send(from_user, to_user, amount, currency)
    end

    state = counter(:dec, state, from_user)
    new_state = counter(:dec, state, to_user)

    {:reply, out, new_state}
  end

  defp counter(:inc, state, user) do
    value = if Map.has_key?(state, user) do
        Map.get(state, user)
      else
        0
      end
    Map.put(state, user, (value-1) )
  end

  defp counter(:dec, state, user) do
    value = if Map.has_key?(state, user) do
        Map.get(state, user)
      else
        0
      end
    Map.put(state, user, (value+1) )
  end

  defp counter(:get, state, user) do
    if Map.has_key?(state, user) do
      Map.get(state, user)
    else
      0
    end
  end

end
