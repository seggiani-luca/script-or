% calcola una base ammissibile di un problema di programmazione lineare
% duale con vettore costo @c, matrice dei vincoli @A e vettore dei vincoli
% @b. nel caso il poliedro sia vuoto, stampa un avviso.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function feasible_B = feasible_primal_simplex(c, A, b, verbose)
    if nargin < 4
        verbose = 0;
    end
    
    [~, A_d, c_d] = dualize(c, A, b);
    [~, optimum] = feasible_dual_simplex(c_d, A_d, verbose - 1);
    feasible_B = get_base(A, b, optimum(1:length(c)), verbose - 1);
end