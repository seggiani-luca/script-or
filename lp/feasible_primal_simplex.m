% calcola una base ammissibile di un problema di programmazione lineare
% duale con vettore costo @c, matrice dei vincoli @A e vettore dei vincoli
% @b. nel caso il poliedro sia vuoto, stampa un avviso.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function feasible_B = feasible_primal_simplex(c, A, b, verbose)
    if nargin < 4
        verbose = 0;
    end
    
    n = width(A);
    m = height(A);

    B = [];

    for i = 1:n
        B(end + 1) = i;
    end
    
    x_B = get_primal_solution(A, b, B);
    res = get_residues(A, b, x_B);

    U = [];
    V = [];

    for i = 1:m
        if res(i) < 0
            V(end + 1) = i;
        else
            U(end + 1) = i;
        end
    end

    if(verbose > 0)
        fprintf("\tB:\n");
        disp(B);
    end

    if(verbose > 1)
        fprintf("\tx_B:\n");
        disp(x_B);
        fprintf("\tResidues:\n");
        disp(res);
    end

    if(verbose > 0)
        fprintf("\tU:\n");
        disp(U); 
        fprintf("\tV:\n")
        disp(V);
    end

    if(res > 0)
        feasible_B = B;
        return;
    end

    num_unsatisfied = height(V);

    B = [B, V];
    new_c = [zeros(1, n), -ones(1, num_unsatisfied)];
    
    new_A = [A, zeros(m, num_unsatisfied)];
    new_b = b;

    for i = 1:num_unsatisfied
        new_A(V(i), i + n) = -1;
    end

    for i = 1:num_unsatisfied
        row = zeros(1, n + num_unsatisfied);
        row(1, n + i) = -1;
        new_A = [new_A; row];
        new_b(end + 1) = 0;
    end

    if(verbose > 0)
        fprintf("\tc:\n");
        disp(new_c);
        fprintf("\tA:\n");
        disp(new_A);
        fprintf("\tb:\n");
        disp(new_b); 
        fprintf("\tB:\n")
        disp(B);
    end

    [optimum, new_B, val] = primal_simplex(new_c, new_A, new_b, B, ...
                                                              verbose - 1);
    if val ~= 0
        fprintf("\tPolyehdron empty.\n");
        feasible_B = [];
        return;
    end

    feasible_B = get_base(A, b, optimum(1:n, 1), verbose - 1);
end