% trova la soluzione ottima di uno zaino intero sfruttando il branch and
% bound. @values rappresenta i valori di ogni oggetto, @weights i pesi e
% @maximum il peso massimo.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum_arg, optimum, b_tree] = integer_knapsack(values, ...
                                                          weights, ...
                                                          maximum, ...
                                                          verbose)

    function new_constraints = get_constraints(node, data, ~)
        constraints = node{2};
        superior = node{4};
        limits = data{5};

        idx = find(mod(superior, 1) ~= 0);

        new_constraints = {};

        for i = 1:limits(idx)
            new_constraints{end + 1} = [constraints, [idx, i]];
        end
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
                if tot < m
                    amt = floor((m - tot) / p(idx));
                    tot = tot + amt * p(idx);
                    inferior(idx) = amt;

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
            idx = find(r == max(r), 1);
            frac = (m - tot) / p(idx);
            % tot = m;
            superior(idx) = frac;
            if(mod(frac, 1) ~= 0) 
                valid = false;
            end
        end
        
        superior_val = eval_value(superior, v);
    end

    if nargin < 4
        verbose = 0;
    end

    returns = values ./ weights;

    limits = floor(maximum ./ weights);

    data = {values, ...  % values
            weights, ... % weights
            maximum, ... % maximum weight
            returns ...  % returns
            limits};     % limits

    if(verbose > 0)
        fprintf("\tReturns:\n");
        disp(returns);
        fprintf("\tLimits:\n");
        disp(limits);
    end

    [b_tree, optimum, optimum_arg] ...
        = branch_and_bound(data, verbose, 'max', ...
                         @inferior_eval, @superior_eval, @get_constraints);
end