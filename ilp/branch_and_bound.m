% implementazione generale del metodo branch and bound. @data è una cella
% (o un oggetto di qualsiasi altro tipo) che @inferior_eval e
% @superior_eval, due handle di funzione, manipolano per ottenere una
% valutazione rispettivamente inferiore e superiore. @get_constraints 
% ottiene una nuova lista di vincoli a partire da un dato nodo. l'algoritmo 
% costruisce l'albero di branch attraverso queste funzioni, restituendo 
% l'albero stesso, il valore ottimo e l'argomento della funzione obiettivo 
% che lo ottiene.
function [branch_tree, optimum, optimum_arg] ...
        = branch_and_bound(data, verbose, ...
                           inferior_eval, superior_eval, get_constraints)

    function print_nodes(node_table)
        num_nodes = height(node_table);
        for i = 1:num_nodes
            row = node_table(i, :);
            node_data = row{:, 2};
            
            disp("<--------------- Subproblem " ...
                + row{:, 1}{:} ...
                + " --------------->");

            fprintf("\tConstraints:\n");
            constraints = node_data{:, 1};
            num_constraints = width(constraints);
            for j = 1:num_constraints
                constraint = constraints{:, j};
                disp("Index " + constraint(1) + ...
                     " constrained at " + constraint(2));
            end

            superior = node_data{:, 2};
            fprintf("\tInferior:\n");
            disp(superior);
            
            inferior = node_data{:, 3};
            fprintf("\tSuperior:\n");
            disp(inferior);

            superior_val = node_data{:, 4};
            fprintf("\tInferior value:\n");
            disp(superior_val);
            
            inferior_val = node_data{:, 5};
            fprintf("\tSuperior value:\n");
            disp(inferior_val);

            implicit = node_data{:, 6};
            fprintf("\tVisited: ");
            if(implicit)
                disp('yes');
            else
                disp('no');
            end

            empty = node_data{:, 7};
            fprintf("\tEmpty: ");
            if(empty)
                disp('yes');
            else
                disp('no');
            end

            fprintf("\n");
        end
    end

    function print_step(step, tree, opt, opt_arg)
        disp("<------------------------------ Branch step " ...
        + step ...
        + " ------------------------------>");
    
        fprintf("\tCurrent optimum:\n");
        disp(opt);
    
        fprintf("\tCurrent optimum argument:\n");
        disp(opt_arg);
    
        node_table = tree.Nodes; 
        print_nodes(node_table);
    end

    function [tree, opt, opt_arg] = branch(tree, data, opt, opt_arg, ...
                                           verbose, step)
        exit = true;

        if(verbose > 1)
            print_step(step, tree, opt, opt_arg);
        end

        for n = 1:height(tree.Nodes)
            if outdegree(tree, n) ~= 0
                continue;
            end
            
            node = tree.Nodes{n, :};
            
            if node{7} == true
                continue;
            end

            tree.Nodes{n, :}{7} = true;

            exit = false;

            new_constraints = get_constraints(node, data);
            num_consts = width(new_constraints)

            tokens = regexp(node{1}, 'P(\d+)-(\d+)', 'tokens');
            i = str2double(tokens{1}{1});
            j = str2double(tokens{1}{2});
            if i == 0
                new_i = 1;
                new_js = 1:num_consts;
            else
                new_i = i + 1;
                new_js = [];
                for d = 1:num_consts
                    new_js(end + 1) = num_consts * j - d + 1;
                end
            end
            
            for d = 1:num_consts
                constraints_dir = new_constraints{d};
                [inferior, inferior_val, inf_valid] ...
                                 = inferior_eval(data, constraints_dir);
                [superior, superior_val, sup_valid] ...
                                 = superior_eval(data, constraints_dir);
   
                implicit = false;
                empty = false;

                if (superior_val <= opt)  || ~inf_valid
                    implicit = true;
                end

                if ~inf_valid
                    empty = true;
                end

                if (superior_val > opt) && sup_valid
                    implicit = true;
                    opt = superior_val;
                    opt_arg = superior;
                end

                if sup_valid
                    implicit = true;
                end

                if (inferior_val > opt) && inf_valid
                    opt = inferior_val;
                    opt_arg = inferior;
                end

                node_data = {constraints_dir, inferior, superior, ...
                        inferior_val, superior_val, implicit, empty};
                name = "P" + new_i + "-" + new_js(d);
   
                tree = addnode(tree, table(name, node_data, ...
                    'VariableNames', {'Name', 'Data'}));
                new_node_idx = height(tree.Nodes);
                tree = addedge(tree, n, new_node_idx);
            end
        end
        if ~exit
            [tree, opt, opt_arg] = branch(tree, data, opt, opt_arg, ...
                                          verbose, step + 1);
        end
    end
    
    [inferior, inferior_val, inf_valid] ...
        = inferior_eval(data, {});
    [superior, superior_val, sup_valid] ...
        = superior_eval(data, {});
    
    p_data = {{}, ...           % constraints
              inferior, ...     % inferior estimate argument
              superior, ...     % superior estimate argument
              inferior_val, ... % inferior estimate value
              superior_val, ... % superior estimate value
              false, ...        % visited
              false};           % empty

    branch_tree = digraph();
    P = table("P0-0", p_data, 'VariableNames', {'Name', 'Data'});
    branch_tree = addnode(branch_tree, P);

    if sup_valid
        opt = superior_val;
        opt_arg = superior;
    elseif inf_valid
        opt = inferior_val;
        opt_arg = inferior;
    else
        fprintf("\tPolyehdron empty.\n");
        return;
    end

    [branch_tree, optimum, optimum_arg] ... 
        = branch(branch_tree, data, opt, opt_arg, verbose, 0);

    if(verbose > 2)
        plot(branch_tree);
    end
    
    if(verbose > 0)
        disp("<------------------------------ Final tree " ...
        + " ------------------------------>");
        print_nodes(branch_tree.Nodes);
    end
end