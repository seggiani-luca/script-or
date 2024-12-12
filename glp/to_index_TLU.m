% converte un'array di celle @TLU contenente i nodi di partenza e arrivo di
% ogni arco di una partizione TLU in un array di celle che contiene gli 
% indici, in un certo grafo @CFG, di tali archi.
% tutte le funzioni che lavorano con TLU si aspettano TLU in questa forma.
function idx_TLU = to_index_TLU(CFG, TLU)
    if length(TLU) == 2 
        [T, U] = deal(TLU{1}, TLU{2});
        idx_T = zeros(length(T), 1);
        idx_U = zeros(length(U), 1);

        for t = 1:length(T)
            idx_T(t) = findedge(CFG, T{t}(1), T{t}(2));
        end
        for u = 1:length(U)
            idx_U(u) = findedge(CFG, U{u}(1), U{u}(2));
        end

        idx_L = [];

        edge_table = table2array(CFG.Edges(:, "EndNodes"));
        for i = 1:height(edge_table)
            edge = edge_table(i, :);
            if ~any(cellfun(@(x) isequal(x, edge), T)) && ~any(cellfun(@(x) isequal(x, edge), U))
                idx_L = [idx_L; i];
            end
        end
    else
        [T, L, U] = deal(TLU{1}, TLU{2}, TLU{3});
        idx_T = zeros(length(T), 1);
        idx_L = zeros(length(L), 1);
        idx_U = zeros(length(U), 1);
    
        for t = 1:length(T)
            idx_T(t) = findedge(CFG, T{t}(1), T{t}(2));
        end
        for l = 1:length(L)
            idx_L(l) = findedge(CFG, L{l}(1), L{l}(2));
        end
        for u = 1:length(U)
            idx_U(u) = findedge(CFG, U{u}(1), U{u}(2));
        end
    end

    idx_TLU = {idx_T, idx_L, idx_U};
end