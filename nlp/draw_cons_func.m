% visualizza una funzione @func di due variabili sul poliedro definito
% definito da @A e @b. @bounds definisce i limiti del grafico come un
% vettore: [min_x, max_x, min_y, max_y).
function draw_cons_func(func, A, b, bounds) % su x1, x2
    syms x1 x2 real;

    if nargin < 4
        vertices = get_vertices(A, b);
        
        min_x = min(vertices(:, 1));
        max_x = max(vertices(:, 1));
        
        min_y = min(vertices(:, 2));
        max_y = max(vertices(:, 2));

        bounds = [min_x - 1, max_x + 1, min_y - 1, max_y + 1];
    end

    x_vec = linspace(bounds(1), bounds(2), 200);
    y_vec = linspace(bounds(3), bounds(4), 200);
    [x_grid, y_grid] = meshgrid(x_vec, y_vec);

    f_func = matlabFunction(func, 'Vars', [x1, x2]);
    z_grid = f_func(x_grid, y_grid);

    points = [x_grid(:), y_grid(:)];

    inside = false(size(points, 1), 1);
    for i = 1:size(points, 1)
        inside(i) = all(A * points(i, :)' <= b');
    end
    inside = reshape(inside, size(x_grid));

    z_grid(~inside) = NaN;

    figure;
    imagesc(x_vec, y_vec, z_grid);
    axis xy;
    colormap('gray');
    colorbar;
    legend;
    xlabel('x1'); ylabel('x2');
    
    hold on;

    for i = 1:height(A)
        if A(i, 2) ~= 0
            expr = (b(:, i) - A(i, 1) * x1) / A(i, 2);
            fplot(matlabFunction(expr), [min(x_vec), max(x_vec)], 'LineWidth', 2);
        elseif A(i, 1) ~= 0
            expr = (b(:, i) - A(i, 2) * x2) / A(i, 2);
            fplot(matlabFunction(expr), [min(y_vec), max(y_vec)], 'LineWidth', 2);
        else
            disp("Can't handle full zero constraint, exiting...");
            return;
        end
    end

    hold off;
end