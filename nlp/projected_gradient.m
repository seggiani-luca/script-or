% implementazione del metodo del gradiente proiettato, che ottimizza la 
% funzione @func sul poliedro definito da @A e @b
function [opt, opt_val] = projected_gradient(func, A, b, x0, verbose, epsilon)
    vars = symvar(func);
    x = []; % ffff
    syms x real;

    function phi = restrict(f, x0, dir)
        substitution = x0' + x * dir;

        phi = subs(f, vars, substitution');
        phi = simplify(phi);
    end

    if nargin < 6
        epsilon = 0.0001;
    end

    if nargin < 5
        verbose = 0;
    end

    func_grad = gradient(func, vars);

    step = 0;

    while true
        if(verbose > 0)
            disp("<------------------------------ Descent step " ...
                + step ...
                + " ------------------------------>");
            fprintf("\tx_k:\n");
            disp(x0);
        end

        act_idx = (A * x0' == b');
        M = A(act_idx, :);
        grad_val = double(subs(func_grad, vars, x0));

        c_step = 0;

        exit = false;

        while true
            proj = M' * inv(M * M') * M;
            H = eye(height(proj)) - proj;
            
            dir = - H * grad_val;

            if(verbose > 0)
                fprintf("\tM:\n");
                disp(M);
                fprintf("\tH:\n");
                disp(H);
                fprintf("\tfunc_1(x_k):\n");
                disp(grad_val);
                fprintf("\td_k:\n");
                disp(dir);                
            end

            c_step = c_step + 1;

            if norm(dir) > epsilon
                break;
            end

            if(verbose > 0)
                disp("d_k null under epsilon, correction step " + c_step);
            end

            l = -inv(M * M') * M * grad_val;
            
            if(verbose > 0)
                fprintf("\tLambda:\n");
                disp(l);
            end

            if l > 0
                exit = true;
                break;
            end

            [~, l_idx] = min(l);
            
            M = M(~l_idx, :);
        end

        if exit == true
            break;
        end

        phi = restrict(func, x0, dir);

        if(verbose > 1)
            fprintf("\nPhi:\n");
            disp(vpa(phi));
        end

        step_tests = (b' - A * x0') ./ (A * dir);
        step_tests = step_tests(isfinite(step_tests) & step_tests > 0);
        max_step = min(step_tests);

        if(verbose > 0)
            fprintf("\nt_hat_k:\t");
            disp(max_step);
        end

        stepsize = exact_cons(phi, max_step);
        x0 = (x0' + stepsize * dir)';
        x0 = double(x0);

        if(verbose > 0)
            fprintf("\nt_k:\t");
            disp(stepsize);
        end

        step = step + 1;
    end

    opt = x0;
    opt_val = double(subs(func, vars, x0));
end