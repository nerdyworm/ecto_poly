defmodule EctoPoly do
  @moduledoc """
  Documentation for EctoPoly.
  """

  defmacro embed_poly(name) do
    quote do
      field(unquote(name), EctoPoly.Type, default: nil)
    end
  end

  def cast_poly(%Ecto.Changeset{} = changeset, name) do
    EctoPoly.Changeset.cast(changeset, name)
  end
end
