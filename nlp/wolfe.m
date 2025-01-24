function [lower, upper] = wolfe(func, a, b, x0, verbose) % su x
    if nargin < 5
        verbose = 0;
    end

    syms x real;
    
    func_1 = diff(func, x);

    armijo = func == subs(func, x, x0) + a * subs(func_1, x, x0) * x;
    goldstein = func_1 == b * subs(func_1, x, x0);

    if(verbose > 0)
        fprintf("\tArmijo:\n");
        disp(armijo);
        fprintf("\tGoldstein:\n");
        disp(goldstein);
    end

    lower = double(solve(goldstein, x));
    
    upper = double(solve(armijo, x));
    upper = upper(isAlways(upper > x0));
end