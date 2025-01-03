% ottiene il vettore dei residui di un problema di programmazione lineare 
% con matrice dei vincoli @A e vettore dei vincoli @b sulla soluzione @x_B.
function residues = get_residues(A, b, x_B)
    residues = b' - A * x_B(:);
    residues(abs(residues) < 0.001) = 0;
end