defmodule App.GetterModule do
  use PostgresListener.Events.Event, name: App

  import PostgresListener.Utils.TransactionFilter

  def process(txn) do
    IO.inspect("Hello")
    cond do
      insert_event?(:user_account, txn) ->
        {:ok, user_account} = event(:user_account, txn)
        IO.inspect(user_account_insert_event: user_account)
        # do something with user_account data

      update_event?(:user_account, txn) ->
        {:ok, user_account} = event(:user_account, txn)
        IO.inspect(user_account_update_event: user_account)

      # you can also specify the relation
      delete_event?("public.user_account", txn) ->
        {:ok, user_account} = event(:user_account, txn)
        IO.inspect(user_account_delete_event: user_account)

      true ->
        nil
    end
  end


end
