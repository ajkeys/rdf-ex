defmodule RDF.Double do
  @moduledoc """
  `RDF.Datatype` for XSD double.
  """

  use RDF.Datatype, id: RDF.Datatype.NS.XSD.double


  def build_literal_by_value(value, opts) do
    case convert(value, opts) do
      float when is_float(float) ->
        build_literal(float, decimal_form(float), opts)
      nil ->
        build_literal(nil, invalid_lexical(value), opts)
      special_value when is_atom(special_value) ->
        build_literal(special_value, nil, opts)
    end
  end


  def convert(value, _) when is_float(value),   do: value

  def convert(value, _) when is_integer(value), do: value / 1

  def convert(value, opts) when is_binary(value) do
    case Float.parse(value) do
      {float, ""} ->
        float
      {float, remainder}  ->
        # 1.E-8 is not a valid Elixir float literal and consequently not fully parsed with Float.parse
        if Regex.match?(~r/^\.e?[\+\-]?\d+$/i, remainder) do
          convert(to_string(float) <> String.trim_leading(remainder, "."), opts)
        else
          super(value, opts)
        end
      :error ->
        case String.upcase(value) do
          "INF"   -> :positive_infinity
          "+INF"  -> :positive_infinity
          "-INF"  -> :negative_infinity
          "NAN"   -> :nan
          _       -> super(value, opts)
        end
    end
  end

  def convert(value, _)
    when value in ~W[positive_infinity negative_infinity nan]a,
    do: value

  def convert(value, opts), do: super(value, opts)


  def canonical_lexical(value) do
    case value do
      :nan                        -> "NaN"
      :positive_infinity          -> "INF"
      :negative_infinity          -> "-INF"
      float when is_float(float)  -> exponential_form(float)
      _                           -> to_string(value)
    end
  end

  def decimal_form(float) when is_float(float) do
    to_string(float)
  end

  def exponential_form(float) when is_float(float) do
    # Can't use simple %f transformation due to special requirements from
    # N3 tests in representation
    [i, f, e] =
      :io_lib.format("~.15e", [float])
      |> List.first
      |> to_string
      |> String.split(~r/[\.e]/)
    f =
      case String.replace(f, ~r/0*$/, "", global: false) do # remove any trailing zeroes
        "" -> "0" # ...but there must be a digit to the right of the decimal point
        f  -> f
      end
    e = String.trim_leading(e, "+")
    "#{i}.#{f}E#{e}"
  end

end
