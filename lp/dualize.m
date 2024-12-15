% trasforma un problema di programmazione lineare in forma primale con
% vettore costo @c, matrice dei vincoli @A e vettore dei vincoli @b, in un
% problema in forma duale introducendo variabili di surplus.
% si noti che la funzione si aspetta problemi primali definiti sul primo
% quadrante (cioè non introduce variabili ausiliarie di segno)
function [b_d, A_d, c_d] = dualize(c, A, b)
    % qua sotto sarebbe utile per problemi definiti sul terzo quadrante, ma
    % non sembra abbastanza generale da tenere, quindi si impone il vincolo
    % di definizione sul primo quadrante
    % for i = 1:width(A)
    %     if c(i) < 0
    %         c(i) = -c(i);
    %         A(:, i) = -A(:, i);
    %     end
    % end
    
    b_d = [-c, zeros(1, height(A))];
    A_d = [A, eye(height(A))]';
    c_d = b;
end