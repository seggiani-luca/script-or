% trova il primo minimo esatto di @func limitata a @x0
function [opt, opt_val] = exact_cons(func, x0) % su x
    syms x real;

    k = 0;
    func_1 = diff(func, x);
    func_2 = diff(func_1, x);

    crits = solve(func_1, x);

    is_valid = (crits < x0) && (crits > 0);
    crits = crits(is_valid);

    func_values = double(subs(func, x, crits));
    [~, idx] = min(func_values);

    if isempty(idx)
        opt_val = +Inf;
    else
        opt = double(crits(idx));
        opt_val = double(subs(func, x, opt));
    end

    if double(subs(func, x, 0)) < opt_val
        opt = 0;
        opt_val = double(subs(func, x, opt));
    end

    if double(subs(func, x, x0)) < opt_val
        opt = x0;
        opt_val = double(subs(func, x, opt));
    end

end