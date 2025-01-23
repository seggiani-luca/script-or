% converte la matrice dei costi @sym_costs di un problema di TSP simmetrico
% nella matrice dei costi di un problema di TSP asimmetrico
function asym_costs = sym_to_asym(sym_costs)
    n = width(sym_costs);

    if height(sym_costs) ~= n
        disp("Cost matrix is not square, exiting");
        return;
    end

    for i = 1:n
        if i > 1 && all(sym_costs(i, 1:(i - 1)) ~= zeros(1, i - 1))
            disp("Lower diagonal row portion at index " ...
                + i ...
                + " is non-zero and will be ignored");
            sym_costs(i, 1:i - 1) = zeros(1, i - 1);
        end
    end

    asym_costs = [zeros(n, 1), sym_costs];
    asym_costs = [asym_costs; zeros(1, n + 1)];

    asym_costs = (asym_costs + asym_costs');
end