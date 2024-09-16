# Computer Vision Algorithms for Representatives Selection

This repository contains MATLAB implementations developed for my diploma thesis titled **"Techniques for Representative Selection from Large Datasets Using Sparse Modeling"**. The focus is on applying the SMRS (Sparse Modeling Representative Selection) algorithm to select representative frames from video data and representative images from image datasets. The SMRS algorithm was originally proposed by Ehsan Elhamifar, Guillermo Sapiro, and René Vidal in their paper **"See All by Looking at a Few: Sparse Modeling for Finding Representative Objects"**.

## Thesis Overview

In my diploma thesis, I explore computational techniques for selecting representative subsets from large, high-dimensional datasets. The ability to efficiently condense data has become increasingly important in recent years due to advancements in artificial intelligence and machine learning. This repository contains MATLAB code developed for extracting representative frames from videos and representative images from datasets, leveraging the SMRS algorithm.

## Features

- Extract representative frames from video sequences using MATLAB.
- Select representative images from large image datasets.
- Implementations based on the SMRS algorithm for optimal representative selection.
- Adaptable to various types of data and applications, including video processing, image analysis, and data compression.

### Acknowledgment

This repository implements the SMRS (Sparse Modeling Representative Selection) algorithm, which was originally developed by Ehsan Elhamifar, René Vidal, and Guillermo Sapiro in their paper **"See All by Looking at a Few: Sparse Modeling for Finding Representative Objects"**. The algorithm presented in this repository is a re-implementation and adaptation of their work.

## Main Files

### 1. `image_processing.m`

This MATLAB script handles the selection of representative images from a dataset. It uses the SMRS algorithm to identify a subset of images that best represent the overall dataset.

To use this script:

1. Make sure you have your image dataset ready in a folder.
2. Edit the `image_processing.m` file to point to the correct path for your dataset.
3. Run the script in MATLAB:

   ```matlab
   run('image_processing.m')
The script will output the representative images.

### 2. `video_processing.m`

This MATLAB script is used to extract representative frames from a video. It also uses the SMRS algorithm to identify key frames that summarize the video effectively.
To use this script:

1. Make sure you have a video file ready.
2. Edit the `video_processing.m` file to specify the path to your video file.
3. Run the script in MATLAB:

   ```matlab
   run('video_processing.m')
The script will output the representative frames.

## Installation

To set up the project locally, follow the steps below:

1. Clone the repository:

   ```bash
   git clone https://github.com/StavLabr/Comp.Vis.Algo.-for-representatives-selection.git
2. Open MATLAB and navigate to the project directory:

   ```bash
   cd 'path_to_repository/Comp.Vis.Algo.-for-representatives-selection'
3. Ensure that the required MATLAB toolboxes are installed.
