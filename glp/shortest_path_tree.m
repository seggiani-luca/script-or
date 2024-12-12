% calcola l'albero dei cammini minimi dal nodo @from su un certo grafo di 
% flusso @FG.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function SPT = shortest_path_tree(FG, from, verbose)
    if nargin < 3
        verbose = 0;
    end

    num_nodes = height(FG.Nodes);
    preds = -ones(1, num_nodes);
    costs = Inf(1, num_nodes);

    preds(from) = 0;
    costs(from) = 0;

    open_set = [];
    for i = 1:num_nodes
        open_set(end + 1) = i;
    end

    tableau = table();
    tableau_labels = ["Step"];
    for i = 1:num_nodes
        tableau_labels(end + 1) = strcat(num2str(i), " P/R");
    end
    tableau_labels(end + 1) = "Exp. node";
    
    step = 0;

    new_row = {step};
    for i = 1:length(costs)
        new_row{end + 1} = [preds(i), costs(i)];
    end
    new_row{end + 1} = NaN;
    tableau(end + 1, :) = new_row;
    tableau.Properties.VariableNames = tableau_labels;

    while length(open_set) ~= 0
        min_val = min(costs(:, open_set));
        min_node = find(costs == min_val, 1, "first");
        f_star = successors(FG, min_node);
        
        for i = 1:length(f_star)
            dest = f_star(i);
            edge_idx = findedge(FG, min_node, dest);
            new_cost = costs(min_node) + FG.Edges.Costs(edge_idx, :);
            if new_cost < costs(dest)
                costs(dest) = new_cost;
                preds(dest) = min_node;
            end
        end
        
        step = step + 1;
        new_row = {step};
        for i = 1:length(costs)
            new_row{end + 1} = [preds(i), costs(i)];
        end
        new_row{end + 1} = min_node;
        tableau(end + 1, :) = new_row;

        open_set(open_set == min_node) = [];
    end

    SPT = digraph();
    for node = num_nodes
        if node == from
            continue
        end
        SPT = addedge(SPT, preds(node), node, costs(node));
    end

    if verbose >= 1
        disp(tableau);
    end
end
