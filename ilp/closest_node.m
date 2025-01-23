% implementazione dell'algoritmo del nodo più vicino per la risoluzione di
% problemi di TSP simmetrici, a partire dal nodo @from.
function [cycle_edges, valid] = closest_node(TSP, from, constraints)
    function match = match_edges(a, b)
        match = all(a == b) || all(flip(a) == b);
    end

    n = height(TSP.Nodes);
    
    visited_nodes = [];
    cycle_edges = {};

    cur_node = from;
    visited_nodes(end + 1) = cur_node;

    edgelist = table2cell(TSP.Edges);
    edgelist = edgelist(:, 1:2);

    edge_matrix = zeros(n, 3);

    for i = 1:height(edgelist)
        edge = [edgelist{i, 1}, edgelist{i, 2}];

        cont = false;
        for j = 1:numel(constraints)
            constraint = constraints{j};
            if match_edges(edge(:, 1:2), constraint(:, 1:2)) && constraint(:, 3) == 0
                cont = true;
            end
        end
        if cont
            continue;
        end

        edge_matrix(i, :) = edge;
    end

    for i = 1:(n - 1)
        cand_rows = edge_matrix(edge_matrix(:, 1) == cur_node, :);
        cand_rows = cand_rows( ...
            ~ismember(cand_rows(:, 2), visited_nodes), :);

        
        cand_row = cand_rows(cand_rows(:, 3) == min(cand_rows(:, 3)), 1:2);

        for j = 1:numel(constraints)
            if constraints{j}(:, 1) == cur_node && constraints{j}(:, 3) == 1
                cand_row = constraints{j}(:, 1:2);
            end
        end
        
        cycle_edges{end + 1} = cand_row;
        cur_node = cand_row(2);
        visited_nodes(end + 1) = cur_node;
    end

    cycle_edges{end + 1} = edge_matrix( ...
                                find(edge_matrix(:, 1) == cur_node ...
                                & edge_matrix(:, 2) == from), 1:2);

end