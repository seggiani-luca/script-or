% trova l'ottimo di un problema di programmazione lineare con vettore costo
% @c, matrice dei vincoli @A e vettore dei vincoli @b, applicando il 
% simplesso primale a partire dalla base @B.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum, optimum_base, value] = primal_simplex(c, A, b, B, ...
                                                                   verbose)
    if nargin < 5
        verbose = 0;
    end

    step = 0;

    while true
        step = step + 1;

        if(verbose > 0)
            disp("<------------------------------ Simplex step " ...
                + step ...
                + " ------------------------------>");
        end

        A_B = A(B, :);
        b_B = b(:, B)';
        x_B = get_primal_solution(A, b, B);
        y_B = get_dual_solution(A, c, B);

        residues = get_residues(A, b, x_B);
        value = dot(x_B, c);

        if(verbose > 0)
            fprintf("\tB:\n");
            disp(B);
        end
        if(verbose > 1)
            fprintf("\tA_B:\n");
            disp(A_B);
            fprintf("\tb_B:\n");
            disp(b_B);
            fprintf("\tValue:\n")
            disp(value);
        end
        if(verbose > 0)
            fprintf("\tx_B:\n");
            disp(x_B);
            fprintf("\ty_B:\n");
            disp(y_B); 
        end
        if(verbose > 1)
            fprintf("\tResidues:\n");
            disp(residues);
        end

        if y_B >= 0
            if verbose > 0
                fprintf("\tOptimum found.\n");
            end
            optimum = x_B;
            optimum_base = B;
            return;
        end

        exit_idx = 0;
        for i = 1:length(y_B)
            if y_B(i) < 0
                exit_idx = i;
                break;
            end
        end

        W = -inv(A_B);
        W_h = W(:, find(B == exit_idx));
        N = [];
        for i = 1:height(A)
            if ~ismember(i, B)
                N(end + 1) = i;
            end
        end

        denoms = zeros(length(N), 1);
        cut_denoms = [];
        cut_N = [];
        empty = true;
        for i = 1:length(N)
            denom = A(N(i), :) * W_h;
            denoms(i) = denom;
            if denom > 0
                empty = false;
                cut_N(end + 1) = N(i);
                cut_denoms(end + 1) = denom;
            end
        end
        
        if empty
            fprintf("\tPolyhedron unbounded.\n");
            return;
        end

        r = zeros(length(cut_N), 1);
        for i = 1:length(cut_N)
            idx = cut_N(i);
            r(i) = residues(idx) / cut_denoms(i);
        end

        min_r = min(r);
        enter_idx = 0;
        for i = 1:length(cut_N)
            if r(i) == min_r
                enter_idx = cut_N(i);
                break;
            end
        end

        if(verbose > 1)
            fprintf("\tW matrix:\n");
            disp(W);
            fprintf("\tDenominators:\n");
            disp(denoms);
            fprintf("\tRatios:\n");
            disp(r);
        end

        if(verbose > 0)
            fprintf("\tExiting index:\n");
            disp(exit_idx);
            fprintf("\tEntering index:\n");
            disp(enter_idx);
        end

        B(B == exit_idx) = [];
        B(end + 1) = enter_idx;
        B = sort(B);
    end
end
