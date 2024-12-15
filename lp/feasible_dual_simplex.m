% calcola una base ammissibile di un problema di programmazione lineare
% duale matrice dei vincoli @A' e vettore dei vincoli
% b'. nel caso il poliedro sia vuoto, stampa un avviso.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [feasible_B, optimum] = feasible_dual_simplex(c, A, verbose)
    if nargin < 3
        verbose = 0;
    end

    n = height(A);
    new_b = [zeros(1, n), ones(1, width(A))];
    
    for i = 1:width(A)
        if c(i) < 0
            c(i) = -c(i);
            A(:, i) = -A(:, i);
        end
    end
    A = [A; eye(width(A))];

    B = [];
    for i = 1:width(A)
        B(end + 1) = i + n;
    end
    [optimum, feasible_B, val] = dual_simplex(c, A, new_b, B, verbose);
    if val ~= 0
        fprintf("\tPolyehdron empty.\n");
        feasible_B = [];
    end
end