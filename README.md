# Bead_Tracker
## Introduction
The app tracks the position of a single bead hold in optical tweezers and output the measurments. Provide a timelapse movie and the script use multilevel image thresholds to find the biggest object in the frame and then fit its perimeter to a circle. There is the option to use a pseudo-Gaussian method (option: Method 2), where we delimit two rings that encompass the bright difraction "ring" that appears around the bead and then find the highest pixel value in that ring circumference. Those are then used to fit in a circle. Lastly, The softare can be used to track the rotational movement (gyration) of the bead around the optical trap.

To identify the bead, the software creates a mask image, which will generate many potential objects (e.g. bead, cells, ...). On first frame, it will take the largest "circular" object near the center, which most likely is the trapped bead; on all following frames it will take the closest best match (by area, shape and position).

## Input
Provide a folder with a stack of .tiff images, which are the sequential frames of the movie. Note: ideally .tiff images should be in the form PREFIX_xyz.tif, where PREFIX is a any name, and xyz a number of N digit. The latter represent frame number and ordering the the images (i.e. labeling using 4 digit numbers, number will be in form 0001 to 9999).

## Using the Bead_Tracker
The GUI of the app looks like this:

![GUI of the app](../main_version/Movie_and_Images/img_GUI.png =572x394)

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

Bead under optical trap |	Circle for tracking Gyration of the Bead
----------------------- | ----------------------------------------
![Movie of BoaB under optical trap](../main_version/Movie_and_Images/Movie_Bead.gif) | ![GUI of the app](../main_version/Movie_and_Images/img_Set_Rotation.png)

The output files are:
  * *BoaB_perim_Circle.txt* - each row is the pixel value of each pixel in the circle perimeter in one frame. Each columns is the same pixel position across all time points. Rows are ordered sequentially from first to last frame
  * *BoaB_vertex_Circle.txt* - it a subset dataset of BoaB_perim_Circle, gathering only 20 equally spaced points of the circle the perimeter.



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


Automatic generated output (Preview End_plot) displaying the R^2 displacement (Ori_Disp) and the Bead radius, using _TC-Track.txt_ file.

![Plot of R^2 and Radius](../main_version/Movie_and_Images/img_Plot_Displacement_Position.png)
