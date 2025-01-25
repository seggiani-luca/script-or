% applica il metodo di Newton a backtracking ad una funzione @func su
% più variabili. @x0 appartiene al metodo di newton, mentre @a, @g e
% @t0 vengono passate così come sono all'algoritmo di backtracking
function [opt, opt_val] = gradient_backtrack(func, a, g, t0, x0, verbose, epsilon)
    vars = symvar(func);
    x = []; % ffff
    syms x real;

    function phi = restrict(f, x0, dir)
        substitution = x0' + x * dir;

        phi = subs(f, vars, substitution');
        phi = simplify(phi);
    end

    if nargin < 7
        epsilon = 0.0001;
    end
    if nargin < 6
        verbose = 0;
    end
    
    func_negrad = -gradient(func, vars);
    func_hess = hessian(func, vars);
    dir = double(subs(func_hess, vars, x0) \ subs(func_negrad, vars, x0));

    step = 0;

    while norm(dir) > epsilon
        if(verbose > 0)
            disp("<------------------------------ Descent step " ...
                + step ...
                + " ------------------------------>");
            
            fprintf("\nx_k:\n");
            disp(x0);
            fprintf("\nd_k:\n");
            disp(dir');
        end

        phi = restrict(func, x0, dir);
        
        if(verbose > 1)
            fprintf("\nPhi:\n");
            disp(vpa(phi));
        end

        stepsize = backtrack(phi, a, g, t0, verbose - 2);
        x0 = (x0' + stepsize * dir)';
        x0 = double(x0);

        if(verbose > 0)
            fprintf("\nt_k:\t");
            disp(stepsize);
        end

        func_negrad = -gradient(func, vars);
        dir = double(subs(func_hess, vars, x0) \ subs(func_negrad, vars, x0));

        step = step + 1;
    end

    opt = x0;
    opt_val = double(subs(func, vars, opt));
end