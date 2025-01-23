% ottiene una funzione di base ammissibile per un grafo di flusso minimo
% @CFG
function base_TLU = feasible_min_flow(CFG, verbose)
    if nargin < 2
        verbose = 0;
    end
    
    new_budgets = [0; CFG.Nodes.Budgets];
    new_edges = CFG.Edges;
    num_edges = height(new_edges);
    new_edges.Costs = zeros(num_edges, 1);
    for i = 1:height(new_edges)
        new_edges(i, :).EndNodes = new_edges(i, :).EndNodes + 1;
    end
    
    T = {};

    for i = 2:length(new_budgets)
        budget = new_budgets(i);
        if budget >= 0
            new_edge = {[1, i], 1, Inf};
        else
            new_edge = {[i, 1], 1, Inf};        
        end
        new_edges = [new_edge; new_edges];
        T{end + 1} = new_edge{1:2};
    end

    new_edges = sortrows(new_edges, [1, 2]);

    aux_CFG = digraph(new_edges.EndNodes(:, 1), new_edges.EndNodes(:, 2));
    aux_CFG.Nodes.Budgets = new_budgets;
    aux_CFG.Edges.Costs = new_edges.Costs;
    aux_CFG.Edges.Caps = new_edges.Caps;

    [MFT, last_TLU] = min_flow_simplex(aux_CFG, {T, {}}, verbose - 1);
    
    edge_table = MFT.Edges;
    T = {};
    for i = 1:height(edge_table)
        edge = edge_table(i, :);
        if edge.Flows ~= 0 && ...
           (edge.EndNodes(:, 1) == 1 || edge.EndNodes(:, 2) == 1) 
            disp("No feasible solution found.");
            return;
        end
    end

    edge_TLU = to_edge_TLU(aux_CFG, last_TLU);

    for i = 1:numel(edge_TLU)
        cur_part = edge_TLU{i};

        keep = true(1, length(cur_part));

        for j = 1:length(cur_part)
            cur_part{j} = cur_part{j} - 1;
            if any(cur_part{j} == 0)
                keep(j) = false;
            end
        end

        cur_part = cur_part(keep);
        
        base_TLU{i} = cur_part;
    end

    base_TLU = to_index_TLU(CFG, base_TLU);

    T = base_TLU{1};

    edge_table = CFG.Edges;

    select_edges = edge_table(T, :);
    cycle_CFG = graph(select_edges.EndNodes(:, 1), ...
                      select_edges.EndNodes(:, 2));
    
    comps = conncomp(cycle_CFG);

    while max(comps) > 1
        old_max = max(comps);
        for i = 1:height(edge_table)
            if ismember(i, T)
                continue;
            end

            T = [T; i];
            
            select_edges = edge_table(T, :);
            cycle_CFG = graph(select_edges.EndNodes(:, 1), ...
                              select_edges.EndNodes(:, 2));
    
            comps = conncomp(cycle_CFG);

            if max(comps) == old_max - 1;
                break;
            end
            
            T(end) = [];
        end
    end

    base_TLU{1} = T;
    base_TLU{2} = setdiff(base_TLU{2}, T);
    base_TLU{3} = setdiff(base_TLU{3}, T);

    base_TLU = to_edge_TLU(CFG, base_TLU);
end