defmodule ExBankingTest do
  use ExUnit.Case, async: true
  alias Decimal
  doctest ExBanking

  @user1 "user1"
  @user2 "user2"
  @user3 "user3"
  @user4 "user4"
  @user_not_exist "Not existing user"
  @user_invalid1 :user
  @user_invalid2 []
  @user_invalid3 10

  @currency1 "usd"
  @currency2 "eur"

  @currency_invalid1 :usd
  @currency_invalid2 []
  @currency_invalid3 10

  @amount1 1
  @amount2 5.0
  @amount3 10
  @amount4 20.0

  @amount_invalid1 :usd
  @amount_invalid2 []
  @amount_invalid3 -10

  setup_all do
    ExBanking.create_user(@user1)
    ExBanking.create_user(@user2)
    :ok
  end

  test "create user" do
    assert :ok == ExBanking.create_user(@user3)
  end

  test "user already exists" do
    assert {:error, :user_already_exists} == ExBanking.create_user(@user1)
  end

  test "deposit" do
    assert {:ok, balance} = ExBanking.deposit(@user1, @amount1, @currency2)
  end

  test "deposit for a user that does not exist" do
    assert {:error, :user_does_not_exist} == ExBanking.deposit(@user_not_exist, @amount2, @currency1)
  end

  test "get balance" do
    assert {:ok, balance} = ExBanking.get_balance(@user1, @currency1)
  end

  test "get balance for a user that does not exists" do
    assert {:error, :user_does_not_exist} == ExBanking.get_balance(@user_not_exist, @currency1)
  end

  test "withdrawal of the user bank account not enough money" do
    ExBanking.create_user(@user4)
    
    assert {:error, :not_enough_money} == ExBanking.withdraw(@user4, @amount1, @currency2)

    assert {:ok, balance} = ExBanking.deposit(@user4, @amount1, @currency1)
    
    assert {:error, :not_enough_money} == ExBanking.withdraw(@user4, @amount2, @currency1)

    assert {:error, :not_enough_money} == ExBanking.withdraw(@user4, @amount1, @currency2)
  end

  test "withdrawal of the user bank account" do
    assert {:ok, _deposit_amt} = ExBanking.deposit(@user1, @amount4, @currency2)
    assert {:ok, balance} = ExBanking.withdraw(@user1, @amount2, @currency2)
  end

  test "withdrawal for a user that does not exists" do
    assert {:error, :user_does_not_exist} == ExBanking.withdraw(@user_not_exist, @amount1, @currency1)
  end

  test "send money from a user that does not exists" do
    assert {:error, :sender_does_not_exist} == ExBanking.send(@user_not_exist, @user2, @amount2, @currency1)
  end

  test "send money from user with not enough money" do
    {:ok, balance} = ExBanking.get_balance(@user1, @currency1)
    assert {:ok, 0} == ExBanking.withdraw(@user1, balance, @currency1)

    assert {:error, :not_enough_money} == ExBanking.send(@user1, @user2, @amount4, @currency1)

    assert {:ok, @amount2} == ExBanking.deposit(@user1, @amount2, @currency1)

    assert {:error, :not_enough_money} == ExBanking.send(@user1, @user2, @amount4, @currency1)
  end

  test "send money to user that does not exists" do
    ExBanking.deposit(@user1, @amount1,  @currency1)

    assert {:error, :receiver_does_not_exist} == ExBanking.send(@user1, @user_not_exist, 1.0, @currency1)
  end

  test "send money" do
    ExBanking.deposit(@user1, 10.0, "usd")
    {_, balance} = ExBanking.get_balance(@user1, "usd")
    withdraw_amt = 5.0
    new_balance = balance - withdraw_amt

    assert {:ok, new_balance, withdraw_amt} == ExBanking.send(@user1, @user2, withdraw_amt, "usd")
  end

  test "limit transfer request" do
    ExBanking.create_user("first_user_limit")
    ExBanking.create_user("second_user_limit")
    ExBanking.deposit("first_user_limit", 1000.00, "usd")
    ExBanking.deposit("second_user_limit", 1000.00, "usd")
    # Test limit request for sender
    1..9999
    |> Enum.each(fn _ ->
      spawn(fn ->
        ExBanking.deposit("first_user_limit", 1.0, "usd")
      end)
    end)

    assert {:error, :too_many_requests_to_sender} == ExBanking.send("first_user_limit", "second_user_limit", 1.0, "usd")

    # Test lmit request for receiver
    1..9999
    |> Enum.each(fn _ ->
      spawn(fn ->
        ExBanking.deposit("second_user_limit", 1.0, "usd")
      end)
    end)

    assert {:error, :too_many_requests_to_receiver} == ExBanking.send("first_user_limit", "second_user_limit", 1.0, "usd")
  end

  test "limit requests" do
    ExBanking.create_user("third_user_limit")

    1..9999
    |> Enum.each(fn _ -> spawn(fn -> ExBanking.deposit("third_user_limit", 1.0, "usd") end) end)

    assert {:error, :too_many_requests_to_user} == ExBanking.get_balance("third_user_limit", "usd")

    1..9999
    |> Enum.each(fn _ -> spawn(fn -> ExBanking.deposit("third_user_limit", 1.0, "usd") end) end)

    assert {:error, :too_many_requests_to_user} == ExBanking.deposit("third_user_limit", 4.0,"usd")

  end

  test "invalid amounts" do
    assert {:error, :wrong_arguments} == ExBanking.deposit(@user1, @amount_invalid1, @currency1)
    assert {:error, :wrong_arguments} == ExBanking.send(@user1, @user2, @amount_invalid2, @currency1)
    assert {:error, :wrong_arguments} == ExBanking.withdraw(@user2, @amount_invalid3, @currency1)
  end

  test "invalid currencies" do
    assert {:error, :wrong_arguments} == ExBanking.deposit(@user1, @amount1, @currency_invalid1)
    assert {:error, :wrong_arguments} == ExBanking.send(@user1, @user2, @amount1, @currency_invalid2)
    assert {:error, :wrong_arguments} == ExBanking.withdraw(@user2, @amount1, @currency_invalid3)
  end

  test "invalid users" do
    assert {:error, :wrong_arguments} == ExBanking.deposit(@user_invalid1, @amount1, @currency1)
    assert {:error, :wrong_arguments} == ExBanking.send(@user_invalid2, @user2, @amount1, @currency1)
    assert {:error, :wrong_arguments} == ExBanking.withdraw(@user_invalid3, @amount1, @currency1)
  end

  test "send money to same user" do
    assert {:error, :wrong_arguments} == ExBanking.send(@user1, @user1, @amount3, @currency1)
  end


end
