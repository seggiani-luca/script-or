% converte un'array di celle di indici che forma una TLU, cioè @TLU, in un
% array di celle che rappresenta la TLU come coppie di nodi terminali di 
% archi in un grafo @CFG
function edge_TLU = to_edge_TLU(CFG, TLU)
    for i = 1:numel(TLU)
        cur_part = TLU{i};
        edges = {};

        for j = 1:length(cur_part)
            edge = cur_part(j);
            CFG_edge = [CFG.Edges.EndNodes(edge, 1), ... 
                        CFG.Edges.EndNodes(edge, 2)];
            edges{end + 1} = CFG_edge;
        end

        edge_TLU{i} = edges;
    end
end