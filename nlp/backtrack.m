function [opt, opt_val] = backtrack(func, a, g, x0, verbose) % su x
    if nargin < 5
        verbose = 0;
    end

    syms x real;

    T = table([], [], [], [], ...
        'VariableNames', {'m', 'g^m * x', 'f(g^m * x)', 'armijo'});

    func_1 = diff(func, x);
    
    m = 0;
    
    gmx = g^m * x0;
    func_val = double(subs(func, gmx));
    armijo = double(subs(func, 0)) + a * double(subs(func_1, 0)) * gmx;

    while func_val > armijo
        new_row = table(m, gmx, func_val, armijo, ...
            'VariableNames', {'m', 'g^m * x', 'f(g^m * x)', 'armijo'});
        T = vertcat(T, new_row);

        m = m + 1;

        gmx = g^m * x0;
        func_val = double(subs(func, gmx));
        armijo = double(subs(func, 0)) + a * double(subs(func, 0)) * gmx;
    end

    new_row = table(m, gmx, func_val, armijo, ...
            'VariableNames', {'m', 'g^m * x', 'f(g^m * x)', 'armijo'});
    T = vertcat(T, new_row);

    if(verbose > 0)
        disp(T);
    end

    opt = (g^m) * x0;
    opt_val = double(subs(func, opt));
end