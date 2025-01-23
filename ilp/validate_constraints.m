% un utilità per convalidare i vincoli di problemi su grafi
function valid = validate_constraints(constraints)
    function val = validate_double(cons_arcs)
        froms = cons_arcs(:, 1);
        tos = cons_arcs(:, 2);
        
        val = (numel(unique(froms)) == numel(froms)) ...
              && (numel(unique(tos)) == numel(tos));
    end

    function val = validate_cycle(cons_arcs)
        val = true;
        if height(cons_arcs) >= 2
            cycle_CFG = graph(cons_arcs(:, 1), ...
                              cons_arcs(:, 2));
        
            cons_cycles = allcycles(cycle_CFG);

            if numel(cons_cycles) ~= 0
                val = false;
            end
        end
    end

    if numel(constraints) == 0
        valid = true;
        return;
    end

    valid = false;

    cons_arcs = cell2mat(constraints');

    on_cons_arcs = cons_arcs(cons_arcs(:, 3) == 1, :);
    on_cons_arcs = on_cons_arcs(:, 1:2);
    
    off_cons_arcs = cons_arcs(cons_arcs(:, 3) == 0, :);
    off_cons_arcs = off_cons_arcs(:, 1:2);

    if ~validate_double(on_cons_arcs)
        return;
    end

    if ~validate_double(off_cons_arcs)
        return;
    end

    if ~validate_cycle(on_cons_arcs)
        return;
    end

    if ~validate_cycle(off_cons_arcs)
        return;
    end

    valid = true;
end