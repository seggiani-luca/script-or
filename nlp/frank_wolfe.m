% implementazione del metodo di Frank-Wolfe, che ottimizza la funzione
% @func sul poliedro definito da @A e @b
function [opt, opt_val] = frank_wolfe(func, A, b, x0, verbose)
    vars = symvar(func);
    x = []; % ffff
    syms x real;

    function opt = solve_linear(c)
        B = feasible_primal_simplex(c', A, b, verbose - 10);
        opt = primal_simplex(c', A, b, B, verbose - 5);
    end

    function phi = restrict(f, x0, dir)
        substitution = x0' + x * dir;

        phi = subs(f, vars, substitution');
        phi = simplify(phi);
    end
    
    if nargin < 4
        verbose = 0;
    end

    func_grad = gradient(func, vars);

    step = 0;

    while true
        if(verbose > 0)
            disp("<------------------------------ Descent step " ...
                + step ...
                + " ------------------------------>");
        end

        c = double(subs(func_grad, vars, x0));
        
        y0 = solve_linear(-c)';
    
        x_val = double(subs(func, vars, x0));
        y_val = double(subs(func, vars, y0));
    
        if(verbose > 0)
            fprintf("\tx_k:\n");
            disp(x0);
            fprintf("\ty_k:\n");
            disp(y0);
            fprintf("\tfunc(x_k)\n");
            disp(x_val);
            fprintf("\tfunc(y_k)\n");
            disp(y_val);
            fprintf("\tc:\n");
            disp(c);
        end

        if dot(c, x0) <= dot(c, y0)
            break;
        end

        dir = (y0 - x0)';
        if(verbose > 0)
            fprintf("\td_k:\n");
            disp(dir);
        end

        phi = restrict(func, x0, dir);

        if(verbose > 1)
            fprintf("\nPhi:\n");
            disp(vpa(phi));
        end

        stepsize = exact_cons(phi, 1);
        x0 = (x0' + stepsize * dir)';
        x0 = double(x0);

        if(verbose > 0)
            fprintf("\nt_k:\t");
            disp(stepsize);
        end

        step = step + 1;
    end

    opt = x0;
    opt_val = x_val;
end