% genera un oggetto digraph (grafo orientato) predisposto alla GLP.
% - @budgets è un vettore numerico che va a popolare una tabella Nodes, 
%   con un unico campo:
%   - Budgets, rappresentate i bilanci sui nodi;
% - @edges è un'array di celle che va a popolare una tabella Edges con
%   campi:
%   - EndNodes, rappresentante i nodi di partenza e arrivo dell'arco;
%   - Costs e Caps, rispettivamente costi e capacità associate agli
%     archi.
function CFG = create_cap_flow_graph(budgets, edges)
    len = length(edges);
    s = zeros(len, 1);
    t = zeros(len, 1);
    costs = zeros(len, 1);
    caps = zeros(len, 1);

    for i = 1:length(edges)
        edge = edges{i};
        
        if length(edge) ~= 4
            disp("Expected 4 scalars, got " ...
                + length(edge) ...
                + " at edge " ...
                + i ...
                + ", skipping");
            continue;
        end
        
        s(i) = edge(1);
        t(i) = edge(2);
        costs(i) = edge(3);
        caps(i) = edge(4);
    end

    CFG = digraph(s, t);
    CFG.Edges.Costs = costs;
    CFG.Edges.Caps = caps;

    CFG.Nodes.Budgets = budgets';
end