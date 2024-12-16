function [cuts, normalized_cuts] = gomory_cut(c, A, b, verbose)
    function frac = frac_part(a)
        frac = a - floor(a);
    end

    if nargin < 4
        verbose = 0;
    end
    
    [b_d, A_d, c_d] = dualize(c, A, b);

    eqs = [];
    for r = 1:width(A_d)
        eq_str = "";
        for col = 1:height(A_d)
            eq_str = eq_str + string(A_d(col, r)) ...
                      + " * " + sprintf("x%d", col);
            if col ~= height(A_d)
                eq_str = eq_str + " + ";
            end
        end
        
        eq_str = eq_str + " = " + c_d(r);

        eqs = [eqs, str2sym(eq_str)];
    end

    new_vars = [];
    new_var_exprs = [];

    for i = (width(A) + 1):height(A_d)
        new_vars = [new_vars, str2sym(sprintf("x%d", i))];
        eq_idx = i - width(A);
        new_var_exprs = [new_var_exprs, ...
                         solve(eqs(eq_idx), new_vars(end))];
    end

    feasible_B = feasible_dual_simplex(c_d, A_d, verbose - 1);
    [x_B, B] = dual_simplex(c_d, A_d, b_d, feasible_B, verbose - 1);
    
    x_B = x_B(B);

    N = [];
    for i = 1:height(A_d)
        if ~ismember(i, B)
            N(end + 1) = i;
        end
    end

    A_B = A_d(B, :);
    A_N = A_d(N, :);

    A_tilde = A_B' \ A_N';

    if(verbose > 1)
        fprintf("\tA_B:\n");
        disp(A_B');
        fprintf("\tA_N:\n");
        disp(A_N');
    end

    if(verbose > 0)
        fprintf("\tA_tilde:\n");
        disp(A_tilde);
    end
   
    cuts = [];
    normalized_cuts = [];

    for r = 1:length(x_B)
        if mod(x_B(r), 1) ~= 0
            lh_side = A_tilde(r, :);
            rh_side = x_B(r);
            
            cut_str = "";
            for n = 1:length(N)
                cut_str = cut_str + string(frac_part(lh_side(n))) ...
                          + " * " + sprintf("x%d", N(n));
                if n ~= length(N)
                    cut_str = cut_str + " + ";
                end
            end
            
            cut_str = cut_str + " >= " + string(frac_part(rh_side));
            cut = str2sym(cut_str);

            normalized_cut = simplify(subs(cut, new_vars, new_var_exprs));

            if(verbose > 0)
               fprintf("< ---- Cut in " + string(r) ...
                       + " (" + x_B(r) + "): ---->\n");
               disp(cut);
            end
            if(verbose > 1)
                fprintf("\tNormalized cut is:\n");
                disp(normalized_cut);
            end

            cuts = [cuts, cut];
            normalized_cuts = [normalized_cuts, normalized_cut];
        end
    end
end