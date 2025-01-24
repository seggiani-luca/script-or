% implementazione dell'algoritmo del nodo più vicino per la risoluzione di
% problemi di TSP simmetrici, a partire dal nodo @from.
function cycle_edges = closest_node(TSP, from, constraints)
    function match = match_edges(a, b)
        match = all(a == b) || all(flip(a) == b);
    end

    n = height(TSP.Nodes);
    
    visited_nodes = [];
    cycle_edges = {};

    cur_node = from;
    visited_nodes(end + 1) = cur_node;

    edge_table = TSP.Edges;
    edge_table = sortrows(edge_table, 2);

    edgelist = table2cell(edge_table);
    edgelist = edgelist(:, 1:2);

    edge_matrix = [];

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

        edge_matrix = [edge_matrix; edge];1;
    end

    function new_edges = closest_step(visited_nodes, edge_matrix, cur_node, i)
        cand_rows = edge_matrix(edge_matrix(:, 1) == cur_node, :);
        cand_rows = cand_rows( ...
            ~ismember(cand_rows(:, 2), visited_nodes), :);

        if i == n
            cand_edges = edge_matrix(find(edge_matrix(:, 1) == cur_node ...
                                   & edge_matrix(:, 2) == from), 1:2);
        else
            cand_edges = cand_rows(:, 1:2);
        end

        for j = 1:numel(constraints)
            constraint = constraints{j};

            if constraint(:, 3) ~= 1
                continue;
            end

            if constraint(:, 1) == cur_node
                if ismember(constraint(2), visited_nodes)
                    continue;
                end

                cand_edges = constraint(:, 1:2);
            end
            if constraint(:, 2) == cur_node
                if ismember(constraint(1), visited_nodes)
                    continue;
                end

                cand_edges = flip(constraint(:, 1:2));
            end
        end


        for j = 1:height(cand_edges)
            cand_edge = cand_edges(j, :);
            mask = all(edge_matrix(:, 1:2) == cand_edge, 2);


            if i == n
                new_edges = {cand_edge};
                return;
            end

            next_node = cand_edge(2);

            returned_edges = closest_step([visited_nodes; next_node], ...
                                          edge_matrix(~mask, :), ...
                                          next_node, ...
                                          i + 1);

            if ~isempty(returned_edges)
                new_edges = [{cand_edge}, returned_edges];
                return;
            end
        end

        new_edges = {};
        return;
    end

    cycle_edges = closest_step(visited_nodes, edge_matrix, cur_node, 1);
end