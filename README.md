% Author: Abdul Qadir
% Date: 26/06/2025
%-------------------
% This script calculates and visualizes the concentration distribution from
% a series of images. It has been enhanced with the following features:
% - Dynamic calibration of concentration range using a reference ROI.
% - Visualization with 'hot' colormap (black-red-yellow-white).
% - Modular code structure for better readability and maintenance.
% - Enhanced user interaction and error handling.
% ------------------------------------------------------------------------

clc; clear; close all;

%% 1. Initialize Parameters
% ------------------------------------------------------------------------
pixequiwid = 0.06;         % mm/pixel

% Visualization and Processing Parameters
color_intensity_factor = 1.2;   % >1 enhances contrast, <1 reduces
overlay_alpha = 0.6;            % Transparency of the concentration overlay
upsample_factor = 5;            % Factor for higher-resolution concentration map
gaussian_sigma = 1.5;           % Smoothing strength for the concentration map
output_resolution = 600;        % DPI for exported graphics

% Concentration settings
concentration_max = 0.1;        % Maximum concentration value for color bar (g/mL)

% File Paths
comdir = 'C:\Experiments\process images';
exp_dir = fullfile(comdir, 'extracted_images\');
result_dir = fullfile(comdir, 'out_put\');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% 2. Select Multiple Images
% ------------------------------------------------------------------------
[filenames, pathname] = uigetfile({'*.bmp;*.png;*.jpg','Image Files (*.bmp,*.png,*.jpg)'}, ...
    'Select Images to Process', exp_dir, 'MultiSelect', 'on');

if isequal(filenames, 0)
    disp('No images selected. Exiting.');
    return;
end

if ischar(filenames)
    filenames = {filenames};  % Ensure it's always a cell array
end

num_images = numel(filenames);

%% 3. Load First Image and Define ROIs
% ------------------------------------------------------------------------
first_im_path = fullfile(pathname, filenames{1});
try
    oriim = imread(first_im_path);
catch ME
    fprintf('Error loading the first image: %s\n', ME.message);
    return;
end

% Convert to grayscale if needed
if size(oriim, 3) == 3
    oriim_gray = rgb2gray(oriim);
else
    oriim_gray = oriim;
end

% Select Analysis ROI
disp('Select the main Region of Interest (ROI) for analysis.');
analysis_rect = selectROI(oriim_gray, 'Select Analysis ROI');
if isempty(analysis_rect)
    disp('Analysis ROI selection cancelled. Exiting.');
    return;
end

% Select Reference ROI for Zero Concentration
disp('Select a reference region for ZERO concentration (e.g., clear fluid).');
reference_rect = selectROI(oriim_gray, 'Select Zero-Concentration Reference ROI');
if isempty(reference_rect)
    disp('Reference ROI selection cancelled. Exiting.');
    return;
end

% Calculate min/max intensity from the reference ROI
ref_roi_im = imcrop(oriim_gray, reference_rect);
min_intensity = double(min(ref_roi_im(:)));
max_intensity = double(max(ref_roi_im(:)));
fprintf('Reference intensity range (min/max): [%.2f, %.2f]\n', min_intensity, max_intensity);

%% 4. Process Each Image
% ------------------------------------------------------------------------
for k = 1:num_images
    fprintf('Processing image %d/%d: %s\n', k, num_images, filenames{k});
    
    img_path = fullfile(pathname, filenames{k});
    current_image = imread(img_path);
    
    % Get the base filename without extension
    [~, base_filename, ~] = fileparts(filenames{k});
    
    processImage(current_image, analysis_rect, min_intensity, max_intensity, ...
                 pixequiwid, upsample_factor, gaussian_sigma, color_intensity_factor, ...
                 overlay_alpha, result_dir, base_filename, output_resolution, concentration_max);
end

disp(' Complete! All images processed with the updated colormap.');

%% Helper Functions

function rect = selectROI(image, title_text)
    % Function to display an image and get a rectangular ROI from the user.
    h_fig = figure;
    imshow(image);
    title(title_text);
    h_roi = imrect;
    if isempty(h_roi)
        rect = [];
    else
        rect = wait(h_roi);
    end
    close(h_fig);
end

function processImage(oriim, rect, min_intensity, max_intensity, pixequiwid, ...
                      upsample_factor, gaussian_sigma, color_intensity_factor, ...
                      overlay_alpha, result_dir, base_filename, resolution, concentration_max)
    % Main function to process a single image.
    % base_filename: The original filename without extension

    % Convert to grayscale if needed
    if size(oriim, 3) == 3
        oriim_gray = rgb2gray(oriim);
    else
        oriim_gray = oriim;
    end

    % Extract ROI
    anarooi = imcrop(oriim_gray, rect);

    % --- Concentration Map Calculation ---
    % Normalize intensity based on the reference ROI
    gray_norm = (double(anarooi) - min_intensity) / (max_intensity - min_intensity);
    gray_norm = 1 - gray_norm; % Invert: dark -> high concentration
    
    % Apply intensity factor and clip the values
    concentration_map = gray_norm * color_intensity_factor;
    concentration_map = max(0, min(1, concentration_map)); % Clip to [0, 1] range

    % Upsample for higher resolution
    concentration_map_hr = imresize(concentration_map, upsample_factor, 'bicubic');

    % Smooth the concentration map
    smooth_map = imgaussfilt(concentration_map_hr, gaussian_sigma);

    % --- Visualization 1: Concentration Map ---
    fig1 = figure('Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
    x_mm = (0:size(smooth_map, 2)-1) * (pixequiwid / upsample_factor);
    y_mm = (0:size(smooth_map, 1)-1) * (pixequiwid / upsample_factor);
    
    % Scale the concentration values to match the 0-0.1 g/mL range
    % This ensures the color variation is preserved while matching the color bar
    scaled_smooth_map = smooth_map * concentration_max;
    
    imagesc(x_mm, y_mm, scaled_smooth_map);
    axis equal tight;
    colormap(jet); % Use 'jet' colormap (blue -> cyan -> yellow -> red) where blue is low and red is high concentration
    
    % Set fixed concentration range for color bar
    caxis([0 concentration_max]);

    % Create color bar with unit
    cb = colorbar('FontSize', 12, 'FontName', 'Times New Roman');
    ylabel(cb, 'Concentration (g/mL)', 'FontSize', 14, 'FontName', 'Times New Roman');
    xlabel('x (mm)', 'FontSize', 14, 'FontName', 'Times New Roman');
    ylabel('y (mm)', 'FontSize', 14, 'FontName', 'Times New Roman');
    title(sprintf('Concentration Distribution: %s', base_filename), 'FontSize', 16);
    
    % Save with original filename + suffix
    output_filename = fullfile(result_dir, sprintf('%s_concentration_map.png', base_filename));
    exportgraphics(fig1, output_filename, 'Resolution', resolution);
    fprintf('Saved concentration map as: %s\n', output_filename);
    close(fig1);

    % --- Visualization 2: Overlay on Original Image ---
    % For overlay, we need to scale the concentration values for color mapping
    % Create an index image scaled to 0-255 range based on 0-0.1 g/mL
    overlay_concentration = smooth_map * concentration_max; % Scale to 0-0.1
    index_image = uint8((overlay_concentration / concentration_max) * 255); % Convert to 0-255
    
    colored_conc = label2rgb(index_image, jet(256), 'k', 'noshuffle');
    
    % Prepare base image for overlay
    base_roi = im2double(anarooi);
    base_roi_rgb = repmat(base_roi, [1, 1, 3]);
    
    % Resize colored concentration map to match ROI size
    colored_conc_resized = imresize(colored_conc, size(anarooi));

    % Create blended overlay
    overlay_img = (1 - overlay_alpha) * base_roi_rgb + overlay_alpha * im2double(colored_conc_resized);

    fig2 = figure('Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
    imshow(overlay_img);
    title(sprintf('Concentration Overlay: %s', base_filename));
    
    % Save with original filename + suffix
    output_filename = fullfile(result_dir, sprintf('%s_concentration_overlay.png', base_filename));
    exportgraphics(fig2, output_filename, 'Resolution', resolution);
    fprintf('Saved concentration overlay as: %s\n', output_filename);
    close(fig2);
end
