% calcola il flusso massimo e il taglio di portata minima su un certo 
% grafo di capacità CG.
% valori crescenti di verbose restituiscono più informazioni sui passaggi 
% intermedi.
function [MFT, cut] = max_flow_min_cut(CG, s, d, verbose)
    function [aug, aug_edges, cut] = get_augmenting_path(GR)
        function queue = enqueue(queue, elem)
            queue = [queue; elem];
        end

        function [queue, elem] = dequeue(queue)
            if ~isempty(queue)
                elem = queue(1);
                queue = queue(2:end);
            else
                error("Queue is empty");
            end
        end

        aug = [];
        aug_edges = [];
        cut = [];

        num_nodes = height(GR.Nodes);
        preds = -ones(1, num_nodes);
        preds(s) = 0;
        pred_edges = preds;

        queue = [s];

        while ~isempty(queue)
            [queue, elem] = dequeue(queue);
            f_star = successors(GR, elem);
            
            keep = true(1, length(f_star));

            for i = 1:length(f_star)
                idx = f_star(i);
                edge = findedge(GR, elem, idx);
                if GR.Edges.Fwd(edge, :) == 0
                    keep(i) = false;
                else
                    if preds(idx) == -1
                        preds(idx) = elem;
                        pred_edges(idx) = edge;
                    end
                end
            end
            
            f_star = f_star(keep);

            if length(find(f_star == d)) ~= 0
                aug = [d];
                aug_edges = [];
                prev = d;
                while prev ~= s
                    aug_edges = [pred_edges(prev), aug_edges];
                    prev = preds(prev);
                    aug = [prev, aug];
                end
                return;
            end

            queue = enqueue(queue, f_star);
            queue = unique(queue);
        end

        cut = find(preds >= 0);
    end

    if nargin < 4
        verbose = 0;
    end

    edge_table = CG.Edges;
    GR = digraph(edge_table.EndNodes(:, 1), ...
                 edge_table.EndNodes(:, 2));
    GR.Edges.Fwd = edge_table.Caps;
    GR.Edges.Bwd= zeros(height(edge_table), 1);
    
    step = 0;

    while true
        step = step + 1;
        
        if(verbose > 0)
            disp("<------------------------------ " + ...
                "Max flow - min cut step " + step ...
                + " ------------------------------>");
        end
        
        [aug, aug_edges, new_cut] = get_augmenting_path(GR);

        if isempty(aug)
            optimal_flow = GR.Edges.Bwd;
            MFT = digraph(edge_table.EndNodes(:, 1), ...
                      edge_table.EndNodes(:, 2));
            MFT.Edges.Flows = optimal_flow;
            cut = new_cut;

            if verbose > 0
                fprintf("\tOptimum found.\n");
            end
            return;
        end

        delta = min(GR.Edges.Fwd(aug_edges, :));
        GR.Edges.Fwd(aug_edges, :) = GR.Edges.Fwd(aug_edges, :) - delta;
        GR.Edges.Bwd(aug_edges, :) = GR.Edges.Bwd(aug_edges, :) + delta;
    
        if verbose > 0
            fprintf("\tAugmenting path:\n");
            disp(aug);
            fprintf("\tDelta:\n");
            disp(delta);
            fprintf("\tForward residues:\n");
            disp(GR.Edges.Fwd);
            fprintf("\tBackward residues:\n");
            disp(GR.Edges.Bwd);

            value = 0;
            for i = 1:height(GR.Edges)
                edge = GR.Edges(i, :);
                if edge.EndNodes(:, 2) == d
                    value = value + edge.Bwd;
                end
            end

            fprintf("\tValue:\n");    
            disp(value);
        end
    end
end