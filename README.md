# Bead_Tracker
### Introduction
The app Bead_Tracker tracks and measures the position of a single bead held in optical tweezers. The software also can be used to track the rotational movement (gyration) of the bead around the optical trap, exploiting the bacteria-on-a-bead system.

All measurements are given as _pixel units_. Using the pixel-micron conversion factor of the micrscoscope setup used to record movies, it possible to analyse the bead displacement and the forces generated for bead shift outside the optical trap.

## Input
Provide a folder with a stack of .tiff images, which are the sequential frames of the movie. Note: ideally .tiff images should be in the form PREFIX_xyz.tif, where PREFIX is a any name, and xyz a number of N digit. The latter represent frame number and ordering the the images (i.e. labeling using 4 digit numbers, number will be in form 0001 to 9999).

## Using the Bead_Tracker
The GUI of the app looks like this:

![GUI of the app](../main_version/Movie_and_Images/img_GUI.png)

### Working Modes
There are two working modes for the app, that can be chosen with the central switch-button in the GUI
1. **BeadTrack** - track the center of the bead. As output it generate a .txt file labeled TC-Track.txt:

![Movie of BoaB under optical trap](../main_version/Movie_and_Images/Movie_Overlay.gif) 

_**TC-Track.txt**_ - the data is organized as follow:
Frame |	X_1 |	Y_1 |	nX_1 |	nY_1 |	Disp |	Ori_Disp |	Radius_1 
----- | --- | --- | ---- | ----- | ----- | --------- | ---------
1.000000 | 98.598571 | 91.951804 | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 20.030492	
2.000000 | 98.389843 | 91.537679 | -0.208728 | -0.414125 | 0.463754 | 0.463754 | 20.046528
... | ... | ... | ... | ... | ... | ... | ... 

The columns values are all in _**pixel**_:
  - *Frame* - column reports frame numbers is followed by the bead center position (as detected from filling to an ellipsoid). 
  - *X_1* and *Y_1* - they are the absolute positions of the bead center. All other columns are calculated using these as raw data.
  - *n_X-1* and *n_X2* - they are the relative positions of the bead center, normalized to the first frame position
  - *Disp* - displacement of the bead from previous frame
  - *Ori_Disp* - displacement of the bead from the ORIgin, which is the position of the bead in the first frame
  - *Radius_1* - Radius of the circle fitted around the detected bead object
<br/><br/>  
2. **Gyration** - to measure the rotational movement of the bead, we exploit the bacteria hanging outside the bead. After starting this analysis mode, draw a large circle around the bead. The value of each pixel that define the perimeter of the drawn circle will be measured and stored in two files. 

Bead under optical trap |	Circle for tracking Gyration  
----------------------- | ---------------------------- 
![Movie of a Bead under optical trap](../main_version/Movie_and_Images/Movie_Bead.gif) | ![GUI of the app](../main_version/Movie_and_Images/img_Set_Gyration.png)

Plotting pixel value of one position along the circle allows to measure the speed and duration of gyration of the bead:
![Img - Setting the cicle to measure gyration](../main_version/Movie_and_Images/img_Plot_Gyration.png)

The output files are:
  * *BoaB_perim_Circle.txt* - each row is the pixel value of each pixel in the circle perimeter in one frame. Each columns is the same pixel position across all time points. Rows are ordered sequentially from first to last frame
  * *BoaB_vertex_Circle.txt* - it a subset dataset of BoaB_perim_Circle, gathering only 20 equally spaced points of the circle the perimeter.


<br/><br/>
### Options and Parameters
Display options, to aid in following if the process is done correctly and plotting the results:
* *Display Bead Fitting*
* *Display Masks*
* *show inner fitting*
* *show outer fitting*
* *show search area*
* *Preview End_plot*

Parameters for analysis
* *T. Levels* - use N levels to perform a multilevel image thresholds (using Otsu’s method) - [if bead has high contrast with background, 2 is sufficient]. 
* *Inner C* - create the inner circle by scaling radius of detected bead of a factor X (<=1) 
* *Outer C* - create the inner circle by scaling radius of detected bead of a factor X (>=1) 

### Results
Automatic generated output (Preview End_plot) displaying the R^2 displacement (Ori_Disp) and the Bead radius, using _TC-Track.txt_ file.

![Plot of R^2 and Radius](../main_version/Movie_and_Images/img_Plot_Displacement_Position.png)

To identify a bead the app uses multilevel image thresholds to find potential objects. The masks of those obejects are filtered to find the potential bead. On first frame, it will take the largest "circular" object near the center, which most likely is the trapped bead; on all following frames it will take the closest best match (by area, shape and position). The bead is then fitted to a circle and will be tracked as proxy of the bead. There is also the option to use a pseudo-Gaussian method (option: Method 2), by creating two circle that encompass the bright difraction "ring" that appears around the bead. The highest pixel value found in the area between the two circles are used to fit in a circle. 
