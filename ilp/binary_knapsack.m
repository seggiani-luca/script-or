% trova la soluzione ottima di uno zaino binario sfruttando il branch and
% bound. @values rappresenta i valori di ogni oggetto, @weights i pesi e
% @maximum il peso massimo.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum_arg, optimum, b_tree] = binary_knapsack(values, ...
                                                          weights, ...
                                                          maximum, ...
                                                          verbose)
    
    function new_constraints = get_constraints(node, ~, ~)
        constraints = node{2};
        superior = node{4};
        idx = find(mod(superior, 1) ~= 0);
        new_constraints = {
            [constraints, [idx, 0]], ...
            [constraints, [idx, 1]] 
        };
    end

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

    function [val] = eval_value(eval, v)
        val = floor(dot(eval, v));
    end

    function [v, p, m, r] = unpack_data(data)
        v = data{1};
        p = data{2};
        m = data{3};
        r = data{4};
    end
    
    function [inferior, inferior_val, valid] = inferior_eval(data, ...
                                                             constraints)
        [v, p, m, r] = unpack_data(data);

        [inferior, tot, r, valid] = constrain(r, p, m, constraints);
        
        if valid
            for i = 1:length(r)
                idx = find(r == max(r), 1);
                if tot + p(idx) <= m
                    tot = tot + p(idx);
                    inferior(idx) = 1;

                    if tot == m
                        break;
                    end

                end
                r(idx) = -Inf;
            end
        end

        inferior_val = eval_value(inferior, v);
    end

    function [superior, superior_val, valid] = superior_eval(data, ...
                                                             constraints)
        [v, p, m, r] = unpack_data(data);

        [superior, tot, r, valid] = constrain(r, p, m, constraints);

        if valid
            for i = 1:length(r)
                if max(r) == -Inf
                    break;
                end
                
                if tot == m
                    break;
                end

                idx = find(r == max(r), 1);
                
                if tot + p(idx) <= m
                    tot = tot + p(idx);
                    superior(idx) = 1;
                else
                    frac = (m - tot) / p(idx);
                    % tot = m;
                    superior(idx) = frac;
                    valid = false;
                    break;
                end
                r(idx) = -Inf;
            end
        end
        
        superior_val = eval_value(superior, v);
    end

    if nargin < 4
        verbose = 0;
    end

    returns = values ./ weights;

    data = {values, ...  % values
            weights, ... % weights
            maximum, ... % maximum weight
            returns};    % return

    if(verbose > 0)
        fprintf("\tReturns:\n");
        disp(returns);
    end

    [b_tree, optimum, optimum_arg] ...
        = branch_and_bound(data, verbose, 'max', ...
                         @inferior_eval, @superior_eval, @get_constraints);
end