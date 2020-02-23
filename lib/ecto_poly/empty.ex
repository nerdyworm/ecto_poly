defmodule EctoPoly.Empty do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:data, :map)
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:data])
  end
end
