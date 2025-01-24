% risolve un problema di TSP simmetrico. @costs è la matrice dei costi, 
% @constraints è una cella contenente i vincoli da applicare ad ogni passo 
% di branch, @from l'indice da cui iniziare l'euristica del nodo più
% vicino, e @k la k dell'euristica del k-albero.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum_arg, optimum, b_tree] = symmetric_TSP(costs, ...
                                                        constraints, ...
                                                        from, k, ...
                                                        verbose)

    function new_constraints = get_constraints(node, ~, step)
        node_constraints = node{2};

        new_constraints = {
            [node_constraints, [constraints{step + 1}, 0]], ...
            [node_constraints, [constraints{step + 1}, 1]]
        };
    end

    function [val] = eval_value(TSP, eval)
        val = 0;

        n = height(TSP.Nodes) / 2;

        for i = 1:length(eval)
            edge = eval{i};
            edge_idx = findedge(TSP, edge(1), edge(2));
            val = val + TSP.Edges.Costs(edge_idx);
        end
    end

    function [inferior, inferior_val, valid] = inferior_eval(~, ...
                                                             constraints)
        valid = validate_constraints(constraints);
        if ~valid
            inferior = {};
            inferior_val = 0;
            return;
        end

        [inferior, valid] = k_tree(TSP, k, constraints);

        inferior_val = eval_value(TSP, inferior);
    end

    function [superior, superior_val, valid] = superior_eval(~, ...
                                                             constraints)
        valid = validate_constraints(constraints);
        if ~valid
            superior = {};
            superior_val = 0;
            return;
        end
        
        superior = closest_node(TSP, from, constraints);

        superior_val = eval_value(TSP, superior);
    end

    if nargin < 5
        verbose = 0;
    end

    TSP = create_sym_tsp_graph(costs);

    [b_tree, optimum, optimum_arg] ...
        = branch_and_bound({}, verbose, 'min', ...
                         @inferior_eval, @superior_eval, @get_constraints, ...
                         numel(constraints) - 1);
end