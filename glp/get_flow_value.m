% calcola il valore del flusso generato da una partizione @TLU su un grafo 
% @CFG
function value = get_flow_value(CFG, flow)
    c = CFG.Edges.Costs(:);
    value = flow' * c;
end