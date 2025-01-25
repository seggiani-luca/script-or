% ottiene i vertici del poliedro definito da @A e @b
function [vertices, intersections] = get_vertices(A, b, verbose)
    if nargin < 3
        verbose = 0;
    end
    
    vertices = [];
    intersections = [];

    for i = 1:height(A)
        for j = (i + 1):height(A)
            if(verbose > 0)
                disp("<------------------------------ Intersect " ...
                + i + " " + j ...
                + " ------------------------------>");
            end
            
            A_s = [A(i, :); A(j, :)];
            b_s = [b(i); b(j)];
            
            intersect = A_s \ b_s;

            intersections = [vertices; intersect'];

            if verbose > 0
                fprintf("\tA_s:\n");
                disp(A_s);
                fprintf("\tb_s:\n");
                disp(b_s);

                fprintf("\tIntersect:\n");
                disp(intersect);
            end

            if all(A * intersect <= b')
                vertices = [vertices; intersect'];
                if(verbose > 0)
                    disp("Point is vertex.");
                end
            end
        end
    end
end