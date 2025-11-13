function plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list, angle_list)

    z_minimo = 999;
    z_massimo = -999;

    for i = 1 : 3 : size(pcd_list,1)
        pcd = pcd_list{i};
        if ~isempty(pcd)

            % === nuova figura per ogni pcd ===
            figure('Name', sprintf('PCD + piani (i = %d)', i));
            ax = gca;

            pts = pcd.Location();

            % nuvola di punti
            pcshow(pcd, "ColorSource", "Intensity", "Parent", ax);
            hold(ax, 'on');   % importantissimo per mantenere i piani

            % griglia comune per entrambi i piani (copre l'estensione dei punti)
            xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
            yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
            [xg, yg] = meshgrid(xrange, yrange);
    
            % ===== piano terreno: a*x + b*y + c*z + d = 0 =====
            g = ground_equation_list(i,:);
            a1 = g(1); b1 = g(2); c1 = g(3); d1 = g(4);
            zg = -(a1*xg + b1*yg + d1) / c1;

            hGround = surf(ax, xg, yg, zg, ...
                'FaceAlpha', 0.55, ...
                'EdgeColor','none', ...
                'FaceColor', [0.20 0.70 0.30]);   % verde

            % ===== piano bici: a*x + b*y + c*z + d = 0 =====
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

            xlabel('X'); ylabel('Y'); zlabel('Z');
            title(sprintf('Piani terreno & bici + PCD (i = %d)\nangle: %.2f', i, angle_list(i)));
            grid on; view(3); axis tight; daspect([1 1 1]);

            z_minimo = min(z_minimo, min(pts(:,3)) - 0.5);
            z_massimo = max(z_massimo, max(pts(:,3)) + 0.5);

            zlim([z_minimo z_massimo]);

            L = ["Terreno","Bici"];
            H = [hGround, hBike];
            H = H(~arrayfun(@isempty,H));
            L = L(1:numel(H));
            if ~isempty(H), legend(H, L, 'Location','best'); end

            set(gcf,'color','w');
            set(ax,'color','w');
            set(ax, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
        end
    end
end