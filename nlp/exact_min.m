% trova il primo minimo esatto di @func
function [opt, opt_val] = exact_min(func) % su x
    syms x real;

    k = 0;
    func_1 = diff(func, x);
    func_2 = diff(func_1, x);

    crits = solve(func_1, x);
    
    is_valid = crits > 0;
    crits = crits(is_valid);

    func_values = double(subs(func, x, crits));
    [~, idx] = min(func_values);

    opt = double(crits(idx));
    opt_val = double(subs(func, x, opt));
end