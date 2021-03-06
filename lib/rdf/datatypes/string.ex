defmodule RDF.String do
  @moduledoc """
  `RDF.Datatype` for XSD string.
  """

  use RDF.Datatype, id: RDF.Datatype.NS.XSD.string


  def build_literal_by_lexical(lexical, opts) do
    build_literal(lexical, nil, opts)
  end


  def convert(value, _), do: to_string(value)


end
