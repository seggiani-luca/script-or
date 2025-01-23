% un implementazione dell'algoritmo delle toppe per una valutazione
% inferiore di un problema di TSP asimmetrico
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [patched_edges, unpatched_edges, p_valid, u_valid] ...
    = patching_algorithm(aTSP, verbose, constraints)
    function cycle_edges = get_edges(cycle_nodes)
        num_nodes = width(cycle_nodes);
        
        cycle_edges = {};

        for i = 1:(num_nodes - 1)
            cycle_edges{end+1} = [cycle_nodes(i), cycle_nodes(i + 1)]; 
        end
        cycle_edges{end + 1} = [cycle_nodes(num_nodes), cycle_nodes(1)];
    end

    function [aTSP, valid] = constrain(aTSP, constraints, n)
        valid = validate_constraints(constraints);

        if ~valid
            return;
        end

        for i = 1:length(constraints)
            constraint = constraints{i};
            
            if constraint(3) == 1
                for i = 1:n
                    if i == constraint(2) || i == constraint(1)
                        continue;
                    end

                    e_idx = findedge(aTSP, constraint(1), i + n);
                    aTSP = rmedge(aTSP, e_idx);
                end
                
            elseif constraint(3) == 0
                e_idx = findedge(aTSP, constraint(1), constraint(2) + n);
                aTSP = rmedge(aTSP, e_idx);
            else
                disp("Can't handle constraint set to" + constraint(3));
                valid = false;
                return;
            end
        end
    end

    function patches = get_patches(l_edges, r_edges)
        l_len = length(l_edges);
        r_len = length(r_edges);

        patches = {};

        for i = 1:l_len
            for j = 1:r_len
                l_edge = l_edges{i};
                r_edge = r_edges{j};
                
                lr_edge = [l_edge(:, 1), r_edge(:, 2)];
                rl_edge = [r_edge(:, 1), l_edge(:, 2)];
                
                patches{end + 1} = {l_edge, r_edge, lr_edge, rl_edge};
            end
        end
    end

    if nargin < 2
        verbose = 0;
    end
    if nargin < 3
        constraints = {};
    end

    n = height(aTSP.Nodes) / 2;

    [constrained_aTSP, p_valid] = constrain(aTSP, constraints, n);

    if ~p_valid
        patched_edges = [];
        unpatched_edges = [];
        u_valid = p_valid;
        return;
    end

    aTSP_base = feasible_min_flow(constrained_aTSP, verbose - 3);
    min_flow = min_flow_simplex(constrained_aTSP, aTSP_base, verbose - 2);

    min_flow_edges = min_flow.Edges;
    selected_edges = min_flow_edges(min_flow_edges.Flows ~= 0, :);

    cycle_graph = digraph(selected_edges.EndNodes(:, 1), ...
                          selected_edges.EndNodes(:, 2) - n);

    end_nodes = cycle_graph.Edges.EndNodes;
    unpatched_edges = num2cell(end_nodes.', 1);

    all_cycles = allcycles(cycle_graph);
    p = length(all_cycles);

    u_valid = (p == 1);

    step = 1;

    while p > 1
        if(verbose > 0)
            disp("<------------------------------ Patch step " ...
                + step ...
                + " ------------------------------>");
        end
    
        if(verbose > 0)
            fprintf("\tCycles:\n");
            disp(all_cycles);
        end
    
        best_patch = {};
        best_patch_cost = +Inf;
        
        chosen_l = 0;
        chosen_r = 0;

        % p sets
        for l = 1:p
            for r = (l + 1):p
                %edges
                l_edges = get_edges(all_cycles{l});
                r_edges = get_edges(all_cycles{r});
    
                patches = get_patches(l_edges, r_edges);
    
                for i = 1:length(patches)
                    patch = patches{i};
    
                    l_idx = findedge(aTSP, patch{1}(1), ...
                                           patch{1}(2) + n);
                    l_cost = aTSP.Edges.Costs(l_idx);
                    
                    r_idx = findedge(aTSP, patch{2}(1), ...
                                           patch{2}(2) + n);
                    r_cost = aTSP.Edges.Costs(r_idx);
                    
                    lr_idx = findedge(aTSP, patch{3}(1), ...
                                            patch{3}(2) + n);
                    lr_cost = aTSP.Edges.Costs(lr_idx);

                    rl_idx = findedge(aTSP, patch{4}(1), ...
                                            patch{4}(2) + n);
                    rl_cost = aTSP.Edges.Costs(rl_idx);
                    
                    patch_cost = -l_cost - r_cost + lr_cost + rl_cost;

                    for i = 1:length(constraints)
                        constraint = constraints{i};

                        if constraint(3) == 1
                            if (constraint(1) == patch{1}(1) ...
                                && constraint(2) == patch{1}(2)) ...
                               || (constraint(1) == patch{2}(1) ...
                                && constraint(2) == patch{2}(2))
                                patch_cost = +Inf;
                            end
                        elseif constraint(3) == 0
                            if (constraint(1) == patch{3}(1) ...
                                && constraint(2) == patch{3}(2)) ...
                               || (constraint(1) == patch{4}(1) ...
                                && constraint(2) == patch{4}(2))
                                patch_cost = +Inf;
                            end
                        else
                            disp("Can't handle constraint set to" ...
                                + constraint(3));
                            return;
                        end
                    end

                    if(verbose > 1)
                        fprintf("\tPatches:\n");
                        disp(patch);
                        disp(patch_cost);
                    end
    
                    if patch_cost < best_patch_cost
                        best_patch_cost = patch_cost;
                        best_patch = patch;

                        chosen_l = l;
                        chosen_r = r;
                    end
                end
            end
        end
    
        if(verbose > 0)
            fprintf("\tBest patch:\n");
            disp(best_patch);
            disp(best_patch_cost);
        end

        l_cycle = all_cycles{chosen_l};
        r_cycle = all_cycles{chosen_r};

        l_edges = get_edges(l_cycle);
        r_edges = get_edges(r_cycle);

        new_edges = {};

        l_start = 0;

        l_num = length(l_edges);

        for i = 1:l_num
            new_edge = l_edges{i};

            if new_edge == best_patch{1}
                new_edges{end + 1} = best_patch{3};
                l_start = i + 1;
                break;
            end

            new_edges{end + 1} = new_edge;
        end

        r_start = find(cellfun(@(x) isequal(x(1), best_patch{3}(2)), ...
                       r_edges));

        r_num = length(r_edges);

        for i = 0:(r_num - 2)
            idx = mod(r_start + i - 1, r_num) + 1;
            new_edges{end + 1} = r_edges{idx};
        end

        new_edges{end + 1} = best_patch{4};

        for i = l_start:l_num
            new_edges{end + 1} = l_edges{i};
        end
        
        new_cycle = [];

        for i = 1:length(new_edges)
            new_cycle(end + 1) = new_edges{i}(1);
        end

        all_cycles(chosen_l) = [];
        all_cycles(chosen_l) = [];
        all_cycles{end + 1} = new_cycle;

        p = length(all_cycles);

        step = step + 1;
    end
    
    patched_edges = get_edges(all_cycles{1});
end