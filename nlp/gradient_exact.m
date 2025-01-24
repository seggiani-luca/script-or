% applica il metodo del gradiente a passo esatto ad una funzione @func su
% più variabili
function [opt, opt_val] = gradient_exact(func, x0, verbose, epsilon)
    vars = symvar(func);
    x = []; % ffff
    syms x real;

    function phi = restrict(f, x0, dir)
        substitution = x0' + x * dir;

        phi = subs(f, vars, substitution');
        phi = simplify(phi);
    end

    if nargin < 4
        epsilon = 0.0001;
    end
    if nargin < 3
        verbose = 0;
    end
    
    func_negrad = -gradient(func, vars);
    dir = double(subs(func_negrad, vars, x0));

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

        stepsize = exact_min(phi);
        x0 = (x0' + stepsize * dir)';
        x0 = double(x0);

        if(verbose > 0)
            fprintf("\nt_k:\t");
            disp(stepsize);
        end

        func_negrad = -gradient(func, vars);
        dir = double(subs(func_negrad, vars, x0));

        step = step + 1;
    end

    opt = x0;
    opt_val = double(subs(func, vars, opt));
end