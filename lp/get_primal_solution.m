% ottiene una soluzione del primale di un problema di programmazione 
% lineare con matrice dei vincoli @A e vettore dei vincoli @b sulla base 
% @B.
function x_B = get_primal_solution(A, b, B)
    A_B = A(B, :);
    b_B = b(:, B)';
    x_B = A_B \ b_B;
    x_B(abs(x_B) < 0.001) = 0;
end