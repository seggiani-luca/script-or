% implementazione dell'euristica del k-albero di copertura per problemi di
% TSP simmetrici
function [tree_edges, valid] = k_tree(TSP, k, constraints)
    function match = match_edges(a, b)
        match = all(a == b) || all(flip(a) == b);
    end

    function MST = kruskal(TSP)
        edgelist = TSP.Edges;
        edgelist = sortrows(edgelist, 2);
        edgelist = edgelist(:, 1);

        MST = {};
        cycle_CFG = graph();

        for i = 1:numel(constraints)
            constraint = constraints{i};

            if constraint(:, 1) == k || constraint(:, 2) == k
                continue;
            end

            if constraint(1) > k
                constraint(1) = constraint(1) - 1;
            end
            if constraint(2) > k
                constraint(2) = constraint(2) - 1;
            end

            MST{end + 1} = constraint(:, 1:2);
            cycle_CFG = addedge(cycle_CFG, constraint(1), constraint(2));
        end
        
        while numel(MST) < height(TSP.Nodes) - 1
            edge = edgelist(1, 1);
            edgelist(1, :) = [];

            cont = false;
            for i = 1:numel(constraints)
                constraint = constraints{i};
    
                if constraint(:, 1) == k || constraint(:, 2) == k
                    continue;
                end
    
                if constraint(1) > k
                    constraint(1) = constraint(1) - 1;
                end
                if constraint(2) > k
                    constraint(2) = constraint(2) - 1;
                end

                if match_edges(edge{1,1}, constraint(:, 1:2)) && constraint(:, 3) == 0
                    cont = true;
                end
            end
            if cont
                continue;
            end

            cycle_CFG = addedge(cycle_CFG, edge);

            if numel(allcycles(cycle_CFG)) ~= 0
                cycle_CFG = rmedge(cycle_CFG, edge{1,1}(1), edge{1,1}(2));
                continue;
            end

            MST{end + 1} = edge{1, 1};
        end
    end

    sub_TSP = rmnode(TSP, k);

    MST = kruskal(sub_TSP);    
    MST = cellfun(@(x) x + (x >= k), MST, 'UniformOutput', false);

    edgelist = TSP.Edges;
    edgelist = sortrows(edgelist, 2);
    edgelist = edgelist(:, 1);

    added_edges = {};

    for i = 1:numel(constraints)
        constraint = constraints{i};
        if constraint(:, 3) == 1 && (constraint(:, 1) == k || constraint(:, 2) == k)
            added_edges{end + 1} = constraint(:, 1:2);
            
            rm_condition1 = all(edgelist.EndNodes == constraint(:, 1:2), 2);
            rm_condition2 = all(edgelist.EndNodes == flip(constraint(:, 1:2)), 2);
            rm_condition = rm_condition1 | rm_condition2;
            
            edgelist = edgelist(~rm_condition, :);
        end
    end

    while numel(added_edges) < 2
        edge = edgelist{1, 1};
        edgelist(1, :) = [];

        if edge(1) ~= k
            continue;
        end

        cont = false;
        for i = 1:numel(constraints)
            constraint = constraints{i};
            if match_edges(edge, constraint(:, 1:2)) && constraint(:, 3) == 0
                cont = true;
            end
        end
        if cont
            continue;
        end
        
        added_edges{end + 1} = edge;
    end

    tree_edges = [MST, added_edges];
    tree_edges = cellfun(@sort, tree_edges, 'UniformOutput', false);

    edge_table = cell2table(tree_edges', 'VariableNames', {'EndNodes'});

    cycle_CFG = graph(edge_table);
    all_cycles = allcycles(cycle_CFG);
    valid = (numel(all_cycles) == 1) && numel(all_cycles{1}) == height(TSP.Nodes);
end