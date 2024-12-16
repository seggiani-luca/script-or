function [optimum_arg, optimum] = binary_knapsack(values, weights, ...
                                                          maximum, verbose)
    function [val, tot, r, valid] = constrain(r, p, m, constraints)
        val = zeros(length(r), 1);
        tot = 0;

        valid = true;

        for i = 1:length(constraints)
            constraint = constraints{i};
            idx = constraint(1); 
            amt = constraint(2);
            r(idx) = -Inf;
            val(idx) = amt;
            tot = tot + p(idx) * amt;
        end

        if tot > m
            valid = false;
            return;
        end
    end
    
    function [inferior, valid] = inferior_eval(r, p, m, constraints)
        [inferior, tot, r, valid] = constrain(r, p, m, constraints);

        if ~valid
            return;
        end

        for i = 1:length(r)
            idx = find(r == max(r), 1);
            if tot + p(idx) <= m
                tot = tot + p(idx);
                inferior(idx) = 1;
                if tot == m
                    return;
                end
            end
            r(idx) = -Inf;
        end
    end

    function [superior, valid] = superior_eval(r, p, m, constraints)
        [superior, tot, r, valid] = constrain(r, p, m, constraints);

        if ~valid
            return;
        end

        for i = 1:length(r)
            if max(r) == -Inf
                return;
            end
            idx = find(r == max(r), 1);
            if tot + p(idx) <= m
                tot = tot + p(idx);
                superior(idx) = 1;
                if tot == m
                    return;
                end
            else
                frac = (m - tot) / p(idx);
                % tot = m;
                superior(idx) = frac;
                return;
            end
            r(idx) = -Inf;
        end
    end

    function valid = is_valid(val)
        valid = isempty(find(mod(val, 1) ~= 0, 1));
    end

    function [tree, opt, opt_arg] = branch(tree, r, p, m, v, opt, opt_arg)
        exit = true;
        for n = 1:height(tree.Nodes)
            if outdegree(tree, n) ~= 0
                continue;
            end
            
            node = tree.Nodes{n, :};
            
            if node{7} == true
                continue;
            end

            tree.Nodes{n, :}{7} = true;

            if is_valid(node{4})
                continue;
            end

            exit = false;
            idx = find(mod(node{4}, 1) ~= 0);
   
            tokens = regexp(node{1}, 'P(\d+)-(\d+)', 'tokens');
            i = str2double(tokens{1}{1});
            j = str2double(tokens{1}{2});
            if i == 0
                new_i = 1;
                new_js = [1, 2];
            else
                new_i = i + 1;
                new_js = [2 * j - 1, 2 * j];
            end
            
            constraints = node{2};
            new_constraints = {
                [constraints, [idx, 0]], ...
                [constraints, [idx, 1]] 
            };
            
            for d = 1:2
                constraints_dir = new_constraints{d};
                [inferior, valid] = inferior_eval(r, p, m, ...
                                                          constraints_dir);
                superior = superior_eval(r, p, m, constraints_dir);
   
                inferior_val = v * inferior;
                superior_val = v * superior;
   
                implicit = false;
                if superior_val <= opt || ~valid
                    % implicita
                    implicit = true;
                end
                if superior_val > opt ...
                   && is_valid(superior_val) ...
                   && valid
                    % implicita con aggiornamento
                    implicit = true;
                    opt = superior_val;
                    opt_arg = superior;
                end

                if inferior_val > opt && valid
                    opt = inferior_val;
                    opt_arg = inferior;
                end

                data = {constraints_dir, inferior, superior, ...
                        inferior_val, superior_val, implicit};
                name = "P" + new_i + "-" + new_js(d);
   
                tree = addnode(tree, table(name, data, ...
                    'VariableNames', {'Name', 'Data'}));
                new_node_idx = height(tree.Nodes);
                tree = addedge(tree, n, new_node_idx);
            end
        end
        if ~exit
            [tree, opt, opt_arg] = branch(tree, returns, weights, ...
                                          maximum, values, opt, opt_arg);
        end
    end 

    if nargin < 4
        verbose = 0;
    end

    returns = values ./ weights;

    inferior = inferior_eval(returns, weights, maximum, {});
    superior = superior_eval(returns, weights, maximum, {});
    inferior_val = values * inferior;
    superior_val = values * superior;

    p_data = {{}, inferior, superior, inferior_val, superior_val, false};

    branch_tree = digraph();
    P = table("P0-0", p_data, 'VariableNames', {'Name', 'Data'});
    branch_tree = addnode(branch_tree, P);

    if is_valid(superior_val)
        opt = superior_val;
        opt_arg = superior;
    else
        opt = inferior_val;
        opt_arg = inferior;
    end
        

    [branch_tree, optimum, optimum_arg] = branch(branch_tree, returns, ...
                                   weights, maximum, values, opt, opt_arg);
                                                                                                                                                                 end