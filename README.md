# Team-COLOR-Sim
Simulation code for the Gemstone Team COLOR. Our simulation generates (and applies) conversion matrices to go from regular RGB images to "color blind" RGB images. This means that the images, to a person without CVD, look approximately how a person with CVD would see them.

Many of our early efforts are documented in the various Matlab files. The most relevant files are `gen_rgb2opp_mat.m`, which generates the conversion matrix (inspired by [Machado et al](https://ieeexplore.ieee.org/document/5290741)), and `MatrixMethod.m`, which applies this conversion matrix to an image. We have also re-implemented these files in Python including clean-ups and necessary customization for our IRB study.

Our simulation can create conversion matrices for red-green color blindness (anomalous trichromacy) for any given strength (-20nm to 20nm). The settings are typically available to change at the top of the Matlab/Python code file.
