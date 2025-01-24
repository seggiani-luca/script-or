% applica il metodo del gradiente a passo fisso ad una funzione @func su
% più variabili. @a rappresenta il passo. se non si fornisce, la funzione
% calcola il passo ottimo come 1/L, con L costante di Lipschitz di @func.
function [opt, opt_val] = gradient_fixed(func, x0, verbose, epsilon, a)
    vars = symvar(func);

    if nargin < 5
        hess = hessian(func, vars);
        eigenvals = eig(hess);
        L = max(abs(eigenvals));
        a = double(1 / L);

        if(verbose > 1)
            fprintf("\tL:\n");
            disp(L);
            fprintf("\ta:\n");
            disp(a);
        end
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
        
        x0 = x0 + a * dir';

        func_negrad = -gradient(func, vars);
        dir = double(subs(func_negrad, vars, x0));

        step = step + 1;
    end

    opt = x0;
    opt_val = double(subs(func, vars, opt));
end