# Human Tetris EEG & Pupillometry Experiment

A MATLAB/Psychtoolbox implementation of a Tetris-based EEG and pupillometry experiment exploring how neural representations of visual objects vary across contexts of action and reward.

## Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts & Functions](#scripts--functions)
- [Data Output](#data-output)
- [Contributing](#contributing)
- [License](#license)

## Overview
This repository contains the code for a five-part experimental paradigm that integrates:
- **EEG recording:** via BioSemi parallel port triggers.
- **Eye-tracking:** using Tobii SDK and pupillometry.
- **Task presentation:** built with Psychtoolbox.

## Repository Structure
/ ├── code/ │ ├── p1.m # Piece presentation section ​p1 │ ├── p2.m # Tableau context section ​p2 │ ├── p4.m # 4-AFC matching section ​p4 │ ├── helperScripts/ # Utility functions │ └── initExperiment.m # Experiment initialization ​initExperiment ├── data/ # Generated data folders per subject └── README.md # This file

markdown
Copy
Edit

## Requirements
- **MATLAB R2023a** or later
- **Psychtoolbox-3** installed
- **Tobii Pro SDK** on the MATLAB path
- **BioSemi parallel port** hardware (if `demoMode` is off)

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/human-tetris-eeg.git
Add subfolders to MATLAB path:

matlab
Copy
Edit
addpath(genpath('path/to/human-tetris-eeg/code'));
Usage
Run each section with:

matlab
Copy
Edit
subjID = 'P01';
demoMode = 0; % Set to 1 to bypass EEG/eye-tracker
p1(subjID, demoMode);
p2(subjID, demoMode);
p4(subjID, demoMode);
Adjust subjID for each participant. Ensure you call initExperiment within each script to handle synchronization and calibration.

Scripts & Functions

Script/Function	Description
p1.m	Part 1: Basic piece presentation (Alone)
p2.m	Part 2: Piece in tableau context
p4.m	Part 4: 4-AFC piece–tableau matching
initExperiment.m	Initializes PTB window, EEG, and eye-tracker calibration
getTetrino.m	Generates Tetris piece textures
getTrig.m	Maps piece + condition to EEG trigger codes
loadPupilData.m	Loads and optionally plots preprocessed pupil traces
preprocessGazeData.m	Cleans, smooths, and timestamps gaze data
calibrateTobii.m	Runs screen-based calibration routine
saveDat.m	Saves behavioral and pupilometry data
Utility scripts	Fixation cross, instructions screens, break timers, etc.
Data Output
Each section saves .mat files under:

css
Copy
Edit
data/<subjID>/
├── eyeData/
├── behavioralData/
├── misc/
└── pX/    % section-specific .mat files
Contributing
Please open issues or pull requests for enhancements, bug fixes, or documentation improvements.

License
This project is licensed under the MIT License. See LICENSE for details.

Copy
Edit
