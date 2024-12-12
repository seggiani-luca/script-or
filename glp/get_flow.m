% calcola il flusso generato da una partizione @TLU su un grafo @CFG
function flow = get_flow(CFG, TLU)
    flow = zeros(height(CFG.Edges), 1);
    
    [T, L, U] = deal(TLU{1}, TLU{2}, TLU{3});
    
    E = CFG.incidence;
    E_T = E(:, T);
    E_U = E(:, U);
    
    b = CFG.Nodes.Budgets(:);
    
    u = CFG.Edges.Caps(:);
    u_U = u(U);
    
    flow(T) = E_T \ (b - E_U * u_U);
    flow(L) = 0;
    flow(U) = u_U;
end