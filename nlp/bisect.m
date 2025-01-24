% biseziona @func fra @a e @b finché la derivata prima non vale meno di
% @epsilon.
function [opt, opt_val] = bisect(func, a, b, verbose, epsilon) % su x
    if nargin < 5
        epsilon = 0.0001;
    end
    if nargin < 4
        verbose = 0;
    end

    syms x real;

    T = table([], [], [], [], [], ...
        'VariableNames', {'k', 'a_k', 'b_k', 'x_k', 'f1(x_k)'});

    k = 0;
    func_1 = diff(func, x);
    diff_a = double(subs(func_1, x, a));

    func_1_diff = Inf;

    while abs(func_1_diff) > epsilon
        m = (a + b) / 2;
        func_1_diff = double(subs(func_1, x, m));
        func_1_val =  diff_a * func_1_diff;

        new_row = table(k, a, b, m, func_1_diff, ...
            'VariableNames', {'k', 'a_k', 'b_k', 'x_k', 'f1(x_k)'});
        T = vertcat(T, new_row);
        
        if func_1_val >= 0
            a = m;
        else % func_1_val < 0
            b = m;
        end

        k = k + 1;
    end

    if(verbose > 0)
        disp(T);
    end

    opt = m;
    opt_val = double(subs(func, x, opt));
end