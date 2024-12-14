% calcola una base ammissibile di un problema di programmazione lineare
% duale con vettore costo @b, matrice dei vincoli @A' e vettore dei vincoli
% b'. nel caso il poliedro sia vuoto, stampa un avviso.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [feasible_B, optimum] = feasible_dual_simplex(c, A, b, verbose)
    if nargin < 4
        verbose = 0;
    end

    new_b = [zeros(1, length(b)), ones(1, width(A))];
    A = [A; eye(width(A))];
    B = [];
    for i = 1:width(A)
        B(end + 1) = i + length(b);
    end
    [optimum, feasible_B, val] = dual_simplex(c, A, new_b, B, verbose);
    if val ~= 0
        fprintf("\tPolyehdron empty.\n");
        feasible_B = [];
    end
end