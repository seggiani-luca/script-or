% genera un oggetto digraph (grafo orientato) predisposto al TSP
% asimmetrico. la matrice @costs è quadrata n * n, e definisce i costi di 
% attraversamento per ogni coppia degli n nodi.
function aTSP = create_asym_tsp_graph(costs)
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

    budgets = [-ones(1, n), ones(1, n)];

    edges = {};

    for i = 1:n
        for j = 1:n
            if i == j
                continue;
            end

            edges{end + 1} = [i, j + n, costs(i, j), 1];
        end
    end

    aTSP = create_cap_flow_graph(budgets, edges);
end