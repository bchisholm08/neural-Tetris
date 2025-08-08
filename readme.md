# **Jean-Paul Noel Neuroscience Lab Human Tetris Experiment**

A neuroscience experiment exploring how neural reprentations of visual objects may vary depending on the context that surrounds an object, and possible actions or rewards an object encodes. 

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
This repository contains the code for a four-part experimental paradigm that integrates:
- **EEG recording:** via BioSemi parallel port triggers.
- **Eye-tracking:** using Tobii SDK.
- **Task presentation:** built with Psychtoolbox.

An overall theme of this experiment is that is increases in complexity throughout. In scripts and functions (LINK HERE) see `p1.m`, `p2.m`, `p4.m` and `p5.m` for more detail on each section.  

## Repository Structure
```
/  
├── code/  
│   ├── humanTetrisWrapper.m # handles running entire experiment
│   ├── helperScripts/   # support functions to run experiment 
│       |── initExperiment.m 
│       |── p1.m
│       |── etc...
├── data/                # Generated data folders per subject  
└── README.md            # This file  
```

## Requirements
- **MATLAB R2023a** or later  
- **Psychtoolbox-3.0.19** installed  
  - PTB requires **GStreamer 1.22.5 (or later)** to be installed 
- **Tobii Pro SDK** on the MATLAB path  
- **BioSemi parallel port** hardware (if `demoMode` is off)  

## News 📰

[//]: # (To make a new entry simply paste :   <tr> )
[//]: # (<td> [] </td>)
[//]: # (    <td> [] </td>)
[//]: # (</tr>)

<table>
  <tr>
    <th>Date</th>
    <th>What Changed</th>
  </tr>
    <tr>
    <td> 7/22/2025 </td>
    <td> First participant data collected! </td>
  </tr>
    <tr>
    <td> 7/14/2025 </td>
    <td> Human EEG & pupillometry pilots </td>
  </tr>
  <tr>
    <td> 6/20/2025 </td>
    <td> Behavioral portion of the experiment is complete. Minor fixes are needed to prepare for data collection. </td>
  </tr>

</table>


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
Each participant is run with one single function call to a wrapper. This will run all experiment sections, give instructions, save data, and close everything at the end. 

The experimenter should only *have* to enter the room if the participant requests it. 

For running with demoMode ON...
```matlab
humanTetrisWrapper("P01")
```  

For running with demoMode OFF...
```matlab
humanTetrisWrapper("P01",0)
```  

 ***NOTE:*** Wrapper function **defaults** to demoMode == 1. This will  bypass EEG/eye‑tracker data collection and run purely the behavioral portion of the experiment. This will still save `.csv` data files. 

## Scripts & Functions
## Experiment Function Reference

### tempFunctionName
**Inputs:**` `
**Outputs**` ` 
**Description** ` ` 

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
└── 







## Contributing
Please open issues or pull requests for enhancements, bug fixes, or documentation improvements.



Don't hesitate to reach out! I can be contacted at two different emails, 
<a href="mailto:chish071@umn.edu" target="_blank">chish071@umn.edu</a>
 or <a href="mailto:bmc@brady-c.cc" target="_blank">bmc@brady-c.cc</a>. 

As of 6/20/2025 this experiment is near deployment in our lab. As we collect data, I will update this repository with preprocessing code we use for analysis. 

## License
This project is licensed under the MIT License. See `LICENSE` for details.
