% ottiene una soluzione del duale di un problema di programmazione lineare 
% con matrice dei vincoli @A e vettore costo @c sulla base @B.
function y_B = get_dual_solution(A, c, B)
    A_B = A(B, :);
    y_B = zeros(1, height(A));
    y_B(:, B) = c / A_B;
    y_B(abs(y_B) < 0.001) = 0;
end