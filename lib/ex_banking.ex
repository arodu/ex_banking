defmodule ExBanking do


  alias ExBanking.Users
  alias ExBanking.Wallet

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

  def start(_type, _args) do
    Wallet.start_link
  end

  @spec create_user(user :: String.t) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    Users.create(user)
  end

  def create_user(_user) do
    {:error, :wrong_arguments}
  end

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) when is_binary(user) and is_number(amount) and amount>=0 and is_binary(currency) do
    Users.deposit(user, amount, currency)
  end

  def deposit(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) when is_binary(user) and is_number(amount) and amount>=0 and is_binary(currency) do
    Users.withdraw(user, amount, currency)
  end

  def withdraw(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    Users.get_balance(user, currency)
  end

  def get_balance(_user, _currency) do
    {:error, :wrong_arguments}
  end

  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency) when is_binary(from_user) and is_binary(to_user) and is_number(amount) and amount>=0 and is_binary(currency) do
    Users.send(from_user, to_user, amount, currency)
  end

  def send(_from_user, _to_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

end
