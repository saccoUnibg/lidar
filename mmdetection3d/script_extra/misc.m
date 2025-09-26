%% .bin -> .pcd
binFileOriginale = 'test.bin';
pcdOriginale = functions.bin_to_pcd(binFileOriginale);
functions.show_pcd(pcdOriginale,"Originale");

%% .pcd -> .bin
% passo pcd + nome file che voglio dargli
fileName='000008_2.bin';
functions.export_bin_from_pcd(pcdOriginale,fileName);

%% Pcd operations: crop, downsample
cropped_pcdTest = functions.crop_pcd(pcdTest);
downsampled_pcdTest = functions.downsample_pcd(cropped_pcdTest,25,0.2); % Downsample by a factor of 0.5