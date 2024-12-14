% ottiene la base che dà soluzione @x_B di un problema di programmazine 
% lineare con matrice dei vincoli @A e vettore dei vincoli @b.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function B = get_base(A, b, x_B, verbose)
    if nargin < 4
        verbose = 0;
    end

    residues = get_residues(A, b, x_B);
    
    if(verbose > 0)
        fprintf("\tResidues:\n");
        disp(residues);
    end

    B = [];
    for i = 1:length(residues)
        if residues(i) == 0
            B(end + 1) = i;
        end
    end
end