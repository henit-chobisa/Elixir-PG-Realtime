
require Protocol

defmodule PostgresListener.Utils.Changes do

  @moduledoc """
  The Modules defines new types for the messages, such as transaction, new record, update record, delete record and truncate record, so that these can be added to JASON.Encoder Protocol to extend parsing of our messages to these types, without us doing anything.
  """

  defmodule(Transaction, do: defstruct([:changes, :commit_timestamp]))

  defmodule(NewRecord,
    do: defstruct([:type, :record, :schema, :table, :columns, :commit_timestamp])
  )

  defmodule(UpdatedRecord,
    do:
      defstruct([
        :type,
        :old_record,
        :record,
        :schema,
        :table,
        :columns,
        :commit_timestamp
      ])
  )

  defmodule(DeletedRecord,
    do: defstruct([:type, :old_record, :schema, :table, :columns, :commit_timestamp])
  )

  defmodule(TruncatedRelation, do: defstruct([:type, :schema, :table, :commit_timestamp]))
end

Protocol.derive(Jason.Encoder, PostgresListener.Utils.Changes.Transaction)
Protocol.derive(Jason.Encoder, PostgresListener.Utils.Changes.NewRecord)
Protocol.derive(Jason.Encoder, PostgresListener.Utils.Changes.UpdatedRecord)
Protocol.derive(Jason.Encoder, PostgresListener.Utils.Changes.DeletedRecord)
Protocol.derive(Jason.Encoder, PostgresListener.Utils.Changes.TruncatedRelation)
