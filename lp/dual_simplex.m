% trova l'ottimo di un problema di programmazione lineare con vettore costo
% @b, matrice dei vincoli @A' e vettore dei vincoli @c, applicando il 
% simplesso duale a partire dalla base @B.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [optimum, optimum_base, value] = dual_simplex(c, A, b, B, verbose)
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
        b_B = b(:, B);
        x_B = get_primal_solution(A, b, B);
        y_B = get_dual_solution(A, c, B);

        residues = get_residues(A, b, x_B);
        value = y_B * b';

        if(verbose > 0)
            fprintf("\tB:\n");
            disp(B);
        end
        if(verbose > 1)
            fprintf("\tA_B:\n");
            disp(A_B);
            fprintf("\tb_B:\n");
            disp(b_B);
        end
        if(verbose > 0)
            fprintf("\tx_B:\n");
            disp(x_B);
            fprintf("\ty_B:\n");
            disp(y_B); 
            fprintf("\tValue:\n")
            disp(value);
        end
        if(verbose > 1)
            fprintf("\tResidues:\n");
            disp(residues);
        end

        is_opt = true;
        enter_idx = 0;
        for i = 1:length(residues)
            if residues(i) < 0
                is_opt = false;
                enter_idx = i;
                break;
            end
        end

        if is_opt
            if verbose > 0
                fprintf("\tOptimum found.\n");
            end
            optimum = y_B;
            optimum_base = B;
            return;
        end

        N = [];
        for i = 1:height(A)
            if ~ismember(i, B)
                N(end + 1) = i;
            end
        end

        W = -inv(A_B);
        A_h = A(enter_idx, :);
        N = [];
        for i = 1:height(A)
            if ~ismember(i, B)
                N(end + 1) = i;
            end
        end

        denoms = zeros(length(N), 1);
        cut_denoms = [];
        cut_B = [];
        empty = true;
        for i = 1:length(B)
            denom = A_h * W(:, i);
            denoms(i) = denom;
            if denom < 0
                empty = false;
                cut_B(end + 1) = B(i);
                cut_denoms(end + 1) = denom;
            end
        end

        if empty
            fprintf("\tPolyhedron unbounded.\n");
            return;
        end

        r = zeros(length(cut_B), 1);
        for i = 1:length(cut_B)
            idx = cut_B(i);
            r(i) = -y_B(idx) / cut_denoms(i);
        end

        min_r = min(r);
        exit_idx = 0;
        for i = 1:length(cut_B)
            if r(i) == min_r
                exit_idx = cut_B(i);
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
            fprintf("\tEntering index:\n");
            disp(enter_idx);
            fprintf("\tExiting index:\n");
            disp(exit_idx);
        end

        B(B == exit_idx) = [];
        B(end + 1) = enter_idx;
        B = sort(B);
    end
end
