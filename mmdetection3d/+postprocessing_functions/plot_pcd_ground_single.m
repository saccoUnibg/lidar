function plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list, angle_list)
    z_minimo = 999;
    z_massimo = -999;

    for i = 1 : 2 : size(pcd_list,1)
        pcd = pcd_list{i};
        if ~isempty(pcd)
            % === nuova figura per ogni pcd ===
            figure('Name', sprintf('Frame %d', i));
            ax = gca;
            pts = pcd.Location();
            
            % nuvola di punti
            pcshow(pcd, "ColorSource", "Intensity", "Parent", ax,"MarkerSize",30);
            hold(ax, 'on');   
            
            % griglia comune
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
            epsC = 1e-12;
            
            if abs(c) < epsC
                hBike = [];
            else
                zb = -(a*xg + b*yg + d) / c;
    
                hBike = surf(ax, xg, yg, zb, ...
                     'FaceAlpha', 0.45, ...
                     'EdgeColor','none', ...
                     'FaceColor',[0.85 0.33 0.10]); % arancio
            end
            
            % --- FORMATTAZIONE VISIVA ---
            
            % 1. Label Assi Grandi
            xlabel('X [m]', 'FontSize', 24, 'FontWeight', 'bold');
            ylabel('Y [m]', 'FontSize', 24, 'FontWeight', 'bold');
            zlabel('Z [m]', 'FontSize', 24, 'FontWeight', 'bold');
            
            % 2. Titolo "Lean Angle"
            title(sprintf('Lean Angle: %.2f°', angle_list(i)), 'FontSize', 24, 'FontWeight', 'bold');
            
            % 3. Numeri sugli assi e impostazioni vista
            ax.FontSize = 10; % Grandezza numeri sui tick
            grid on; view(3); axis tight; daspect([1 1 1]);
            
            % Limiti Z dinamici (come nel tuo script originale)
            z_minimo = min(z_minimo, min(pts(:,3)) - 0.5);
            z_massimo = max(z_massimo, max(pts(:,3)));
            zlim([-1.5 z_massimo]);
            
            % 4. Legenda Grande
            L = ["Ground", "Bike"]; % Ho messo inglese per coerenza con "Lean Angle", rimetti "Terreno" se preferisci
            %H = [hGround, hBike];
            
            % Rimuove handle vuoti se il piano bici non esiste
            mask = ~arrayfun(@isempty, L);
            %H = H(mask);
            %L = L(mask);
            
            if ~isempty(L)
                lgd = legend(L, 'Location', 'best');
                lgd.FontSize = 40;      % <--- Legenda INGRANDITA
                lgd.FontWeight = 'bold';
            end
            
            % Colori sfondo
            set(gcf,'color','w');
            set(ax,'color','w');
            set(ax, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
        end
    end
end