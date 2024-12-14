function reduced_costs = get_reduced_costs(CFG, potential)
    c = CFG.Edges.Costs(:);
    E = CFG.incidence;
    
    reduced_costs = c - E' * potential';
end