function plot_pcd_ground_sequence(ground_equation_list, bike_equation_list, pcd_list, angle_list)
    z_minimo = 999;
    z_massimo = -999;
    
    % Se vuoi assicurarti che usi la figura corrente o ne crei una nuova pulita
    % figure('Name', 'Sequence'); 
    ax = gca;

    for i = 1 : 2 : size(pcd_list,1)
        pcd = pcd_list{i};
        if ~isempty(pcd)
            pts = pcd.Location();
    
            % --- Nuvola di punti ---
            pcshow(pcd, "ColorSource", "Intensity", "Parent", ax,"MarkerSize",30);
            hold(ax, 'on');
    
            % --- Griglia comune ---
            xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
            yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
            [xg, yg] = meshgrid(xrange, yrange);
    
            % ===== piano terreno =====
            g = ground_equation_list(i,:);
            a1 = g(1); b1 = g(2); c1 = g(3); d1 = g(4);
            zg = -(a1*xg + b1*yg + d1) / c1;
    
            hGround = surf(ax, xg, yg, zg, ...
                'FaceAlpha', 0.55, ...
                'EdgeColor','none', ...
                'FaceColor', [0.20 0.70 0.30]);   % verde
    
            % ===== piano bici =====
            bq = bike_equation_list(i,:);
            a = bq(1); b = bq(2); c = bq(3); d = bq(4);
        
            hBike = [];
            epsC = 1e-12;
            if abs(c) >= epsC
                zb = -(a*xg + b*yg + d) / c;
    
                hBike = surf(ax, xg, yg, zb, ...
                    'FaceAlpha', 0.45, ...
                    'EdgeColor','none', ...
                    'FaceColor',[0.85 0.33 0.10]); % arancio
            end
    
            % --- FORMATTAZIONE VISIVA ---
            
            % 1. Label Assi Grandi e Nomi corretti
            xlabel(ax, 'X [m]', 'FontSize', 20, 'FontWeight', 'bold');
            ylabel(ax, 'Y [m]', 'FontSize', 20, 'FontWeight', 'bold');
            zlabel(ax, 'Z [m]', 'FontSize', 20, 'FontWeight', 'bold');
            
            % 2. Titolo Grande "Lean Angle"
            % Visualizza anche il numero del frame per riferimento
            title(ax, sprintf('Lean Angle: %.2f° (Frame %d)', angle_list(i), i), ...
                  'FontSize', 24, 'FontWeight', 'bold');
            
            % 3. Numeri sugli assi e impostazioni vista
            ax.FontSize = 15; 
            grid(ax, 'on'); 
            view(ax, 3); 
            axis(ax, 'tight'); 
            daspect(ax, [1 1 1]);
    
            % Calcolo limiti Z
            z_minimo = min(z_minimo,min(pts(:,3)) - 0.5);
            z_massimo = max(z_massimo,max(pts(:,3)) + 0.5);
            zlim(ax, [z_minimo z_massimo]);
            
            % 4. Legenda Grande
            L = ["Ground", "Bike"];
            H = [hGround, hBike];
            
            % Filtra handle vuoti (se hBike non esiste in questo frame)
            mask = ~arrayfun(@isempty, H);
            H = H(mask);
            L = L(mask);
            
            if ~isempty(H)
                lgd = legend(ax, H, L, 'Location','best');
                lgd.FontSize = 18;      % <--- Legenda INGRANDITA
                lgd.FontWeight = 'bold';
            end
            
            % Forza l'aggiornamento grafico ad ogni iterazione
            drawnow;
        end
    end
    
    % Impostazioni finali colori sfondo
    set(gcf,'color','w');
    set(ax,'color','w');
    set(ax, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
    
    % Reimposta i limiti Z calcolati durante l'intera sequenza
    zlim(ax, [z_minimo z_massimo]);
end