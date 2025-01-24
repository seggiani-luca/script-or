% risolve un problema di TSP asimmetrico. @costs è la matrice dei costi, e
% @constraints una cella contenente i vincoli da applicare ad ogni passo di 
% branch.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum_arg, optimum, b_tree] = asymmetric_TSP(costs, ...
                                                         constraints, ...
                                                         verbose)

    function new_constraints = get_constraints(node, ~, step)
        node_constraints = node{2};

        new_constraints = {
            [node_constraints, [constraints{step + 1}, 0]], ...
            [node_constraints, [constraints{step + 1}, 1]]
        };
    end

    function [val] = eval_value(aTSP, eval)
        val = 0;

        n = height(aTSP.Nodes) / 2;

        for i = 1:length(eval)
            edge = eval{i};
            edge_idx = findedge(aTSP, edge(1), edge(2) + n);
            val = val + aTSP.Edges.Costs(edge_idx);
        end
    end
    
    function [inferior, inferior_val, valid] = inferior_eval(~, ...
                                                             constraints)
        [superior_c, inferior, sup_valid_c, valid] ...
            = patching_algorithm(aTSP, verbose - 5, constraints);

        inferior_val = eval_value(aTSP, inferior);
    end

    function [superior, superior_val, valid] = superior_eval(~, ~)
        superior = superior_c;
        valid = sup_valid_c;
        superior_val = eval_value(aTSP, superior);
    end

    if nargin < 3
        verbose = 0;
    end

    aTSP = create_asym_tsp_graph(costs);

    superior_c = [];     % siamo "sicuri" che la branch_and_bound chiamerà
    sup_valid_c = false; % prima inferior_eval e poi superior_eval, e visto
                         % che l'algoritmo delle toppe trova entrambe
                         % facciamo tutti i calcolli in inferior_eval e
                         % memoizziamo le soluzioni di superior_eval.
                         % progettualmente è orribile ma ho sonno

    [b_tree, optimum, optimum_arg] ...
        = branch_and_bound({}, verbose, 'min', ...
                         @inferior_eval, @superior_eval, @get_constraints, ...
                         numel(constraints) - 1);
end