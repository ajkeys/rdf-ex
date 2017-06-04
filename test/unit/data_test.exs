defmodule RDF.DataTest do
  use RDF.Test.Case

  setup do
    description =
      EX.S
      |> EX.p1(EX.O1, EX.O2)
      |> EX.p2(EX.O3)
      |> EX.p3(~B<foo>, ~L"bar")
    graph =
      Graph.new
      |> Graph.add(description)
      |> Graph.add(
          EX.S2
          |> EX.p2(EX.O3, EX.O4)
      )
    {:ok,
      description: description,
      graph: graph
    }
  end


  describe "RDF.Data protocol implementation of RDF.Description" do
    test "delete", %{description: description} do
      assert RDF.Data.delete(description, {EX.S, EX.p1, EX.O2}) ==
          Description.delete(description, {EX.S, EX.p1, EX.O2})
      assert RDF.Data.delete(description, {EX.Other, EX.p1, EX.O2}) == description
    end

    test "deleting a Description with a different subject does nothing", %{description: description} do
      assert RDF.Data.delete(description,
              %Description{description | subject: EX.Other}) == description
    end

    test "pop", %{description: description} do
      assert RDF.Data.pop(description) == Description.pop(description)
    end

    test "include?", %{description: description} do
      assert RDF.Data.include?(description, {EX.S, EX.p1, EX.O2})
      refute RDF.Data.include?(description, {EX.Other, EX.p1, EX.O2})
    end

    test "statements", %{description: description} do
      assert RDF.Data.statements(description) == Description.statements(description)
    end

    test "subjects", %{description: description} do
      assert RDF.Data.subjects(description) == MapSet.new([uri(EX.S)])
    end

    test "predicates", %{description: description} do
      assert RDF.Data.predicates(description) == MapSet.new([EX.p1, EX.p2, EX.p3])
    end

    test "objects", %{description: description} do
      assert RDF.Data.objects(description) ==
              MapSet.new([uri(EX.O1), uri(EX.O2), uri(EX.O3), ~B<foo>])
    end

    test "resources", %{description: description} do
      assert RDF.Data.resources(description) ==
              MapSet.new([uri(EX.S), EX.p1, EX.p2, EX.p3, uri(EX.O1), uri(EX.O2), uri(EX.O3), ~B<foo>])
    end

    test "subject_count", %{description: description} do
      assert RDF.Data.subject_count(description) == 1
    end

    test "statement_count", %{description: description} do
      assert RDF.Data.statement_count(description) == 5
    end
  end


  describe "RDF.Data protocol implementation of RDF.Graph" do
    test "delete", %{graph: graph} do
      assert RDF.Data.delete(graph, {EX.S, EX.p1, EX.O2}) ==
                Graph.delete(graph, {EX.S, EX.p1, EX.O2})
      assert RDF.Data.delete(graph, {EX.Other, EX.p1, EX.O2}) == graph
    end

    test "deleting a Graph with a different name does nothing", %{graph: graph} do
      assert RDF.Data.delete(graph,
              %Graph{graph | name: EX.OtherGraph}) == graph
    end

    test "pop", %{graph: graph} do
      assert RDF.Data.pop(graph) == Graph.pop(graph)
    end

    test "include?", %{graph: graph} do
      assert RDF.Data.include?(graph, {EX.S, EX.p1, EX.O2})
      assert RDF.Data.include?(graph, {EX.S2, EX.p2, EX.O3})
      refute RDF.Data.include?(graph, {EX.Other, EX.p1, EX.O2})
    end

    test "statements", %{graph: graph} do
      assert RDF.Data.statements(graph) == Graph.statements(graph)
    end

    test "subjects", %{graph: graph} do
      assert RDF.Data.subjects(graph) == MapSet.new([uri(EX.S), uri(EX.S2)])
    end

    test "predicates", %{graph: graph} do
      assert RDF.Data.predicates(graph) == MapSet.new([EX.p1, EX.p2, EX.p3])
    end

    test "objects", %{graph: graph} do
      assert RDF.Data.objects(graph) ==
              MapSet.new([uri(EX.O1), uri(EX.O2), uri(EX.O3), uri(EX.O4), ~B<foo>])
    end

    test "resources", %{graph: graph} do
      assert RDF.Data.resources(graph) == MapSet.new([
              uri(EX.S), uri(EX.S2), EX.p1, EX.p2, EX.p3,
              uri(EX.O1), uri(EX.O2), uri(EX.O3), uri(EX.O4), ~B<foo>
             ])
    end

    test "subject_count", %{graph: graph} do
      assert RDF.Data.subject_count(graph) == 2
    end

    test "statement_count", %{graph: graph} do
      assert RDF.Data.statement_count(graph) == 7
    end
  end

end
