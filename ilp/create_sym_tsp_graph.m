% genera un oggetto digraph (grafo orientato) predisposto al TSP simmetrico 
% la matrice @costs è quadrata n * n, e definisce i costi di 
% attraversamento per ogni coppia degli n nodi.
function TSP = create_sym_tsp_graph(costs)
    if costs(1, 1) ~= 0
        costs = sym_to_asym(costs);
    end

    n = width(costs);

    if height(costs) ~= n
        disp("Cost matrix is not square, exiting");
        return;
    end

    for i = 1:n
        if costs(i, i) ~= 0
            disp("Diagonal element at index " ...
                + i ...
                + " is non-zero and will be ignored");
        end
    end

    edges = {};

    for i = 1:n
        for j = 1:n
            if i == j
                continue;
            end

            edges{end + 1} = [i, j, costs(i, j)];
        end
    end

    TSP = create_flow_graph(zeros(1, n), edges);
end