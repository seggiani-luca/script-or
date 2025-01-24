function [opt, opt_val] = newton(func, x0, verbose, epsilon) % su x
    if nargin < 4
        epsilon = 0.0001;
    end
    if nargin < 3
        verbose = 0;
    end

    syms x real;

    T = table([], [], [], [], ...
        'VariableNames', {'k', 'x_k', 'f1(x_k)', 'f2(x_k)'});

    k = 0;
    func_1 = diff(func, x);
    func_2 = diff(func_1, x);

    func_1_diff = Inf;

    while abs(func_1_diff) > epsilon
        func_1_diff = double(subs(func_1, x, x0));
        func_2_diff = double(subs(func_2, x, x0));
        
        new_row = table(k, x0, func_1_diff, func_2_diff, ...
            'VariableNames', {'k', 'x_k', 'f1(x_k)', 'f2(x_k)'});
        T = vertcat(T, new_row);

        x0 = x0 - func_1_diff / func_2_diff;

        k = k + 1;
    end

    if(verbose > 0)
        disp(T);
    end

    opt = x0;
    opt_val = double(subs(func, x, x0));
end