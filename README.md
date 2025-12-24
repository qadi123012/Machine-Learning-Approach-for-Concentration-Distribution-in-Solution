# Machine-Learning-Approach-for-Concentration-Distribution-in-Solution
This MATLAB script computes and visualizes spatial concentration distributions from a sequence of experimental images. It is designed for image-based concentration analysis where grayscale intensity variations are mapped to physical concentration values within a selected region of interest (ROI).

The workflow emphasizes flexibility, user interaction, and reproducible visualization, making it suitable for experimental post-processing and comparative analysis across multiple images.

Key Capabilities

Batch processing of multiple images selected by the user

Interactive selection of analysis and reference regions

Dynamic calibration of concentration values using a zero-concentration reference ROI

Conversion of image intensity to concentration using normalized grayscale values

High-resolution concentration mapping through upsampling and smoothing

Export of publication-quality figures with fixed physical units and color scaling

Generation of both standalone concentration maps and overlays on original images

Processing Workflow
1. Initialization and Parameters

The script begins by defining physical scaling, visualization controls, and processing parameters, including:

Pixel-to-length conversion (mm per pixel)

Contrast enhancement and transparency factors

Upsampling factor for higher spatial resolution

Gaussian smoothing strength

Maximum concentration value for visualization

Output image resolution for export

Input and output directories are also defined, and the output folder is created automatically if it does not exist.

2. Image Selection

The user selects one or more image files using a graphical file selection dialog. The script handles both single and multiple selections and exits safely if no images are chosen.

3. ROI Definition and Calibration

From the first selected image:

The user interactively selects:

A main analysis ROI where concentration will be computed

A reference ROI corresponding to zero concentration (for example, clear fluid)

The reference ROI is used to determine minimum and maximum grayscale intensity values

These values define the normalization range for all subsequent images, ensuring consistent calibration

4. Concentration Map Calculation

For each image:

The image is converted to grayscale if necessary

The analysis ROI is cropped

Pixel intensities are normalized using the reference ROI range

Intensities are inverted so darker regions correspond to higher concentration

A configurable intensity scaling factor is applied

Values are clipped to ensure valid concentration bounds

The resulting normalized concentration field is then upsampled using bicubic interpolation and smoothed with a Gaussian filter to reduce noise and improve visual continuity.

5. Visualization Outputs

The script produces two types of outputs for each image:

A. Concentration Map

Displays concentration distribution in physical coordinates (millimeters)

Uses a fixed concentration range from 0 to a user-defined maximum value

Includes labeled axes and a color bar with physical units

Exported as a high-resolution PNG suitable for reports or publications

B. Concentration Overlay

Overlays the color-mapped concentration data onto the original grayscale ROI

Uses adjustable transparency for clear visual comparison

Preserves spatial alignment with the original image

Exported as a separate high-resolution image

Modularity and Error Handling

The code is organized into helper functions to improve readability and maintainability:

ROI selection is handled through a dedicated function

Image processing and visualization are encapsulated in a single processing function

Basic error handling ensures safe exit on image loading or user cancellation

Intended Use

This script is intended for:

Experimental image-based concentration analysis

Visualization of scalar fields derived from optical measurements

Batch processing of datasets with consistent calibration

Generating figures for scientific analysis and reporting

It is not intended as a fully automated measurement tool, but as a controlled, user-guided analysis pipeline where calibration and interpretation remain explicit.
