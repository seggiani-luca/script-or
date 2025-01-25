% visualizza una funzione @func di due variabili. @bounds definisce i 
% limiti del grafico come un vettore: [min_x, max_x, min_y, max_y).
function draw_free_func(func, bounds) % su x1, x2
    syms x1 x2 real;

    x_vec = linspace(bounds(1), bounds(2), 200);
    y_vec = linspace(bounds(3), bounds(4), 200);
    [x_grid, y_grid] = meshgrid(x_vec, y_vec);

    f_func = matlabFunction(func, 'Vars', [x1, x2]);
    z_grid = f_func(x_grid, y_grid);

    points = [x_grid(:), y_grid(:)];

    figure;
    imagesc(x_vec, y_vec, z_grid);
    axis xy;
    colormap('turbo');
    colorbar;
    xlabel('x1'); ylabel('x2');
end