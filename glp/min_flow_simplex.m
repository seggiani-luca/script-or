% applica il simplesso su grafi a un oggetto digraph (grafo orientato),
% partendo da una partizione TLU di base.
% - @CFG è il digrafo su cui applicare il simplesso;
% - @baseTLU è la partizione TLU di indici da cui partire;
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function MFT = min_flow_simplex(CFG, baseTLU, verbose)
    function reduced_costs = get_reduced_costs(p)
        c = CFG.Edges.Costs(:);
        E = CFG.incidence;
        
        reduced_costs = c - E' * p';
    end

    function [cycle_p, cycle_m] = get_cycle(enter_idx, T, direction)
        function found = find_in_cell(edge, cell_edges) 
            found = any(cellfun(@(v) isequal(v, edge), ...
                         cell_edges));
        end

        function swapped = swap_members(cell_edges)
            swapped = cellfun(@(v) [v(2), v(1)], cell_edges, ...
                              'UniformOutput', false);
        end
        
        edge_table = CFG.Edges;
        select_edges = edge_table(T, :);
        cycle_CFG = graph(select_edges.EndNodes(:, 1), ...
                          select_edges.EndNodes(:, 2));
        
        all_cycles = allcycles(cycle_CFG);
        cycle_nodes = all_cycles{1};
        
        cycle_edges = {};
        num_nodes = length(cycle_nodes);
        for i = 1:(num_nodes - 1)
            cycle_edges{end+1} = [cycle_nodes(i), cycle_nodes(i + 1)]; 
        end
        cycle_edges{end + 1} = [cycle_nodes(num_nodes), cycle_nodes(1)];

        all_edges = CFG.Edges{:, 1};
        enter_edge = all_edges(enter_idx, :);
        
        edge_found = find_in_cell(enter_edge, cycle_edges);

        if(xor(~edge_found, strcmp(direction, "reversed")))
            cycle_edges = swap_members(cycle_edges);
        end

        num_edges = length(cycle_edges);

        cycle_p = [];
        cycle_m = [];

        for i = 1:num_edges
            edge = cycle_edges{i};
            if ismember(edge, all_edges, "rows")
                cycle_p(end+1) = findedge(CFG, edge(1), edge(2));
            else
                cycle_m(end+1) = findedge(CFG, edge(2), edge(1));
            end
        end
    end
    
    if nargin < 3
        verbose = 0;
    end

    if length(baseTLU{1}{1}) == 2
        baseTLU = to_index_TLU(CFG, baseTLU);
    end

    TLU = baseTLU;
    step = 0;
    
    while true
        step = step + 1;

        if(verbose > 0)
            disp("<------------------------------ Simplex step " ...
                + step ...
                + " ------------------------------>");
        end

        [T, L, U] = deal(TLU{1}, TLU{2}, TLU{3});

        all_edges = CFG.Edges{:, 1};
    
        if(verbose > 0)
            fprintf("\tPartitions:\n")
            fprintf("\t\tT:\n");
            disp(all_edges(T, :));
            fprintf("\t\tL:\n");
            disp(all_edges(L, :));
            fprintf("\t\tU:\n");
            disp(all_edges(U, :));
        end

        flow = get_flow(CFG, TLU);
        potential = get_potential(CFG, TLU);

        if verbose > 0
            fprintf("\tFlow:\n");
            disp(flow');
            fprintf("\tPotential:\n");
            disp(potential);

            value = get_flow_value(CFG, flow);

            fprintf("\tValue:\n\t");
            disp(value);
        end

        r_costs = get_reduced_costs(potential);

        if all(r_costs(L) >= 0) && all(r_costs(U) <= 0)
            if verbose > 0
                fprintf("\tOptimum found.\n");
            end
            break;
        end
        
        l_enter_idxs = [];
        for i = 1:length(L)
            l = L(i);
            if r_costs(l) < 0
                l_enter_idxs(end + 1) = l;
            end
        end
    
        u_enter_idxs = [];
        for i = 1:length(U)
            u = U(i);
            if r_costs(u) > 0
                u_enter_idxs(end + 1) = u;
            end
        end
    
        enter_idx = min([l_enter_idxs, u_enter_idxs]);
        
        direction = "forward";
        if(ismember(enter_idx, U)) 
            direction = "reversed";
        end
        
        T = [T; enter_idx];
        L(L == enter_idx) = [];
        U(U == enter_idx) = [];
    
        [cycle_p, cycle_m] = get_cycle(enter_idx, T, direction);
        
        u = CFG.Edges.Caps(:);
    
        u_p = u(cycle_p);
        x_p = flow(cycle_p);
        x_m = flow(cycle_m);
    
        theta_p = min(u_p - x_p);
        theta_m = min(x_m);
        theta = min(theta_p, theta_m);
    
        p_exit_idxs = cycle_p(u(cycle_p) - flow(cycle_p) == theta);
        m_exit_idxs = cycle_m(flow(cycle_m) == theta);
        exit_idx = min([p_exit_idxs, m_exit_idxs]);
    
        T(T == exit_idx) = [];
        if(ismember(exit_idx, p_exit_idxs))
            U = [U; exit_idx];
        else
            L = [L; exit_idx];
        end
    
        T = sortrows(T);
        L = sortrows(L);
        U = sortrows(U);

        TLU = {T, L, U};
    
        if verbose > 1
            fprintf("\tReduced costs:\n");
            disp(r_costs);
            fprintf("\tPositive cycle:\n");
            disp(all_edges(cycle_p, :));
            fprintf("\tNegative cycle:\n");
            disp(all_edges(cycle_m, :));
            fprintf("\tPositive theta:\n");
            disp(theta_p);
            fprintf("\tNegative theta:\n");
            disp(theta_m);
            fprintf("\tTheta:\n")
            disp(theta);
        end
    
        if verbose > 0
            fprintf("\tEntering edge:\n");
            disp(all_edges(enter_idx, :));
            fprintf("\tExiting edge:\n");
            disp(all_edges(exit_idx, :));
        end
    end

    optimal_flow = get_flow(CFG, TLU);
    edge_table = CFG.Edges;
    MFT = digraph(edge_table.EndNodes(:, 1), ...
                 edge_table.EndNodes(:, 2));
    MFT.Edges.Flows = optimal_flow;
end