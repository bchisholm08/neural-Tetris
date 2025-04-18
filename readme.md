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
```  
/  
├── code/  
│   ├── p1.m             # Piece presentation section :contentReference[oaicite:0]{index=0}&#8203;:contentReference[oaicite:1]{index=1}  
│   ├── p2.m             # Tableau context section :contentReference[oaicite:2]{index=2}&#8203;:contentReference[oaicite:3]{index=3}  
│   ├── p4.m             # 4-AFC matching section :contentReference[oaicite:4]{index=4}&#8203;:contentReference[oaicite:5]{index=5}  
│   ├── helperScripts/   # Utility functions  
│   └── initExperiment.m # Experiment initialization :contentReference[oaicite:6]{index=6}&#8203;:contentReference[oaicite:7]{index=7}  
├── data/                # Generated data folders per subject  
└── README.md            # This file  
```

## Requirements
- **MATLAB R2023a** or later  
- **Psychtoolbox-3** installed  
- **Tobii Pro SDK** on the MATLAB path  
- **BioSemi parallel port** hardware (if `demoMode` is off)  

## Installation
1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/human-tetris-eeg.git
   ```
2. Add subfolders to MATLAB path:  
   ```matlab
   addpath(genpath('path/to/human-tetris-eeg/code'));
   ```

## Usage
Run each section with:  
```matlab
subjID = 'P01';
demoMode = 0; % Set to 1 to bypass EEG/eye‑tracker
p1(subjID, demoMode);
p2(subjID, demoMode);
p4(subjID, demoMode);
```  
Adjust `subjID` for each participant. Ensure you call `initExperiment` within each script to handle synchronization and calibration.

## Scripts & Functions
## Experiment Function Reference

### humanTetrisWrapper
**Inputs:** `subjID`  
**Outputs:** _None_  
**Purpose:** A clean wrapper for the experiment. Passes `subjID` to `p1()`, `p2()`, etc., so the experimenter can run just this one function.  
**Notes:** Calls `breakScreen` between sections.

### p1() and p1Instruct() 
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Facilitates section one of the experiment (piece presentation alone).  
**Notes:** Uses `p1Instruct()` to display instructions.

### p2() and p2Instruct()
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Facilitates section two of the experiment (piece in tableau context).  
**Notes:** Uses `p2Instruct()` to display instructions.

### p3() and p3Instruct()
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Facilitates section three of the experiment (interactive matching without reward).  
**Notes:** Uses `p3Instruct()` to display instructions.

### p4() and p4Instruct() 
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Facilitates section four of the experiment (4-AFC piece–tableau matching).  
**Notes:** Uses `p4Instruct()` to display instructions.

### p5() and p5Instruct()
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Facilitates section five of the experiment (final integration).  
**Notes:** Uses `p5Instruct()` to display instructions.

---

### calibrateTobii
| Input        | Type    | Description                            |
| ------------ | ------- | -------------------------------------- |
| `window`     | Handle  | PTB window pointer                     |
| `windowRect` | Rect    | PTB window rectangle                   |
| `eyetracker` | Object  | Tobii eyetracker handle                |
| `params`     | Struct  | Experiment parameters                  |

**Outputs:**  
- `calibrationData` (struct): Contains calibration results if saved.  

**Purpose:** Performs native Tobii calibration, then offers recalibration or save options at the end.

---

### drawFixation
**Inputs:** `window`, `windowRect`, `color`  
**Outputs:** _None_  
**Purpose:** Draws a horizontal and vertical line at the center of the screen as a fixation cross.

---

### getTableaus
**Inputs:** _None_  
**Outputs:** _None_  
**Purpose:** Defines and generates all Tetris tableaux textures for context trials.  
**Notes:** Should build a `struct()` of textures; consider offloading heavy logic from `pX` scripts.

---

### getTetrino
**Inputs:** `params`  
**Outputs:** `pieces` (struct array)  
**Purpose:** Creates Tetris piece textures and metadata in a struct for presentation.

---

### getTrig 
**Inputs:** `piece`, `eventType`  
**Outputs:** `trig` (integer)  
**Purpose:** Maps a Tetris piece and event type to an EEG trigger code.

---

### initExperiment
**Inputs:** `subjID`, `demoMode`, `baseDataDir`  
**Outputs:** `window`, `windowRect`, `expParams`, `ioObj`, `address`, `eyetracker`  
**Purpose:** Initializes Psychtoolbox, sync tests, experiment parameters, EEG I/O, and eye-tracker connection/calibration.

---

### saveDat
**Inputs:** `section`, `subjID`, `data`, `params`, `demoMode`  
**Outputs:** _None_  
**Purpose:** Saves behavioral and pupillometry data (or demo log) to organized subject folders.  
**Notes:** Complex logic — may simplify with MATLAB’s `save()`.

---

### take5Brubeck
**Inputs:** `window`, `params`  
**Outputs:** _None_  
**Purpose:** Displays a break screen between blocks with a progress bar.  
```markdown


## Data Output
Each section saves `.mat` files under:
```  
data/<subjID>/  
├── eyeData/  
├── behavioralData/  
├── misc/  
└── pX/    % section-specific .mat files  
```

## Contributing
Please open issues or pull requests for enhancements, bug fixes, or documentation improvements.

## License
This project is licensed under the MIT License. See `LICENSE` for details.
