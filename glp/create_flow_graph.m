% wrapper di create_cap_flow_graph() per grafi di flusso non capacitato
function FG = create_flow_graph(edges)
    function res = add_cap(edge)
        res = [edge, Inf];
    end
    
    max_inter = cellfun(@(x) max(x(1:2)), edges);
    nodes = zeros(1, max(max_inter));
    edges = cellfun(@add_cap, edges, "UniformOutput", false);
    FG = create_cap_flow_graph(nodes, edges);
end