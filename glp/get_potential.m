% calcola il potenziale generato da una partizione @TLU su un grafo @CFG
function potential = get_potential(CFG, TLU)
    potential = zeros(height(CFG.Nodes), 1);
    
    [T, L, U] = deal(TLU{1}, TLU{2}, TLU{3});
    
    E = CFG.incidence;
    E_T = E(:, T);
    
    c = CFG.Edges.Costs(:);
    c_T = c(T);

    potential = c_T' / E_T;
    potential = potential - potential(1);
end