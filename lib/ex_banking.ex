defmodule ExBanking do

  alias ExBanking.Monitor

  @type banking_error :: {:error,
    :wrong_arguments                |
    :user_already_exists            |
    :user_does_not_exist            |
    :not_enough_money               |
    :sender_does_not_exist          |
    :receiver_does_not_exist        |
    :too_many_requests_to_user      |
    :too_many_requests_to_sender    |
    :too_many_requests_to_receiver
  } 

  @bucket ExBanking.Monitor

  def start(_type, _args) do
    ExBanking.Supervisor.start_link([])
  end


  @spec create_user(user :: String.t) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    Monitor.create(@bucket, user)
  end

  def create_user(_user) do
    {:error, :wrong_arguments}
  end

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) when is_binary(user) and is_number(amount) and amount>=0 and is_binary(currency) do
    spawn(fn -> Monitor.init_process(@bucket, user) end)
    Monitor.deposit(@bucket, user, amount, currency)
  end

  def deposit(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) when is_binary(user) and is_number(amount) and amount>=0 and is_binary(currency) do
    spawn(fn -> Monitor.init_process(@bucket, user) end)
    Monitor.withdraw(@bucket, user, amount, currency)
  end

  def withdraw(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end


  @spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    spawn(fn -> Monitor.init_process(@bucket, user) end)
    Monitor.get_balance(@bucket, user, currency)
  end

  def get_balance(_user, _currency) do
    {:error, :wrong_arguments}
  end


  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency) when is_binary(from_user) and is_binary(to_user) and is_number(amount) and amount>=0 and is_binary(currency) do
    spawn(fn -> Monitor.init_process(@bucket, from_user) end)
    spawn(fn -> Monitor.init_process(@bucket, to_user) end)
    Monitor.send(@bucket, from_user, to_user, amount, currency)
  end

  def send(_from_user, _to_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end
  

end
