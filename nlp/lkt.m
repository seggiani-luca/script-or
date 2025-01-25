function  solutions = lkt(func, g, h, verbose, x0)
    vars = symvar(func);
    
    if nargin < 4 
        verbose = 0;
    end

    num_ineq = length(g);
    num_eq = length(h);
    
    lambda = sym('lambda', [num_ineq, 1], 'real');
    mu = sym('mu', [num_eq, 1], 'real');
    
    grad_f = gradient(func, vars);
    grad_g = jacobian(g, vars);
    grad_h = jacobian(h, vars);
    
    kkt_stationarity = grad_f + grad_g.' * lambda + grad_h.' * mu;
    kkt_primal_feasibility = [h; g];
    kkt_complementary_slackness = lambda .* g;
    
    if nargin >= 5
        kkt_stationarity = subs(kkt_stationarity, vars, x0);
        kkt_primal_feasibility = subs(kkt_primal_feasibility, vars, x0);
        kkt_complementary_slackness= subs(kkt_complementary_slackness, vars, x0);
    end

    kkt_system = [
        kkt_stationarity;
        % kkt_primal_feasibility;
        kkt_complementary_slackness;
    ];

    if(verbose > 0)
        disp(kkt_system);
    end
    
    solutions = solve(kkt_system, [vars, lambda.', mu.'], "Real", true);
    
    sol_table = struct2table(solutions);

    disp(sol_table);
end