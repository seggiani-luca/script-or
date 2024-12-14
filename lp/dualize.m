% trasforma un problema di programmazione lineare in forma primale con
% vettore costo @c, matrice dei vincoli @A e vettore dei vincoli @b, in un
% problema in forma duale introducendo variabili di surplus.
function [b_d, A_d, c_d] = dualize(c, A, b)
    b_d = [-c, zeros(1, height(A))];
    A_d = [A, eye(height(A))]';
    c_d = b;
end