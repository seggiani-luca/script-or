% trova il primo minimo esatto di @func
function [opt, opt_val] = exact_min(func) % su x
    if nargin < 4
        epsilon = 0.0001;
    end
    if nargin < 3
        verbose = 0;
    end

    syms x real;

    k = 0;
    func_1 = diff(func, x);
    func_2 = diff(func_1, x);

    crits = solve(func_1, x);
    is_min = double(subs(func_2, x, crits)) > 0;
    
    crits = crits(is_min == 1);

    opt = crits(1);
    opt_val = double(subs(func, x, opt));
end