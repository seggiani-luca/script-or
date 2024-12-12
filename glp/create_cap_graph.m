% wrapper di create_cap_flow_graph() per i grafi capacitati senza costo
% associato e senza bilanci ai nodi (pensata per i grafi di flusso massimo)
function CG = create_cap_graph(edges)
    function res = add_cost(edge)
        res = [edge(1:2), 0, edge(3)];
    end

    max_inter = cellfun(@(x) max(x(1:2)), edges);
    nodes = zeros(1, max(max_inter));
    edges = cellfun(@add_cost, edges, "UniformOutput", false);
    CG = create_cap_flow_graph(nodes, edges);
end