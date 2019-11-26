defmodule ExBanking.Users do

  alias ExBanking.Wallet

  def create(user) do
    if Wallet.exist?(user) do
      {:error, :user_already_exists}
    else
      Wallet.create(user)
    end
  end


  def deposit(user, amount, currency) do
    if Wallet.exist?(user) do
      current = Wallet.get(user, currency)
      Wallet.set(user, (current+amount), currency)
      {:ok, Wallet.get(user, currency)}
    else
      {:error, :user_does_not_exist}
    end
  end


  def withdraw(user, amount, currency) do
    if Wallet.exist?(user) do
      current = Wallet.get(user, currency)
      if amount <= current do
        Wallet.set(user, (current-amount), currency)
        {:ok, Wallet.get(user, currency)}
      else
        {:error, :not_enough_money}
      end
    else
      {:error, :user_does_not_exist}
    end
  end


  def send(from_user, to_user, amount, currency) do
    cond do
      !(Wallet.exist?(from_user)) ->
          {:error, :sender_does_not_exist}

      !(Wallet.exist?(to_user)) ->
          {:error, :receiver_does_not_exist}

      from_user == to_user ->
          {:error, :wrong_arguments}

      amount > Wallet.get(from_user, currency) ->
          {:error, :not_enough_money}

      true -> 
          withdraw(from_user, amount, currency)
          deposit(to_user, amount, currency)
          {:ok, Wallet.get(from_user, currency), Wallet.get(to_user, currency)}
    end
  end


  def get_balance(user, currency) do
    if Wallet.exist?(user) do
      {:ok, Wallet.get(user, currency)}
    else
      {:error, :user_does_not_exist}
    end
  end
  

end