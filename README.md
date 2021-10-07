# Bead_Tracker
The app tracks the position of a single bead hold in optical tweezers. Providing a timelapse movie (as a stack of .tiff images) the script use multilevel image thresholds to find the biggest object in the frame and then fit its perimeter to a circle. There is the option to use a pseudo-Gaussian method (option: Method 2), where we delimit two rings that encompass the bright difraction ring of the bead and then find the highest pixel value in that ring circumference. Those are then used to fit in a circle.


Determine analysis parameters of the movies using the GUI of the app. 
![GUI of the app](../main_version/Movie_and_Images/img_GUI.png)

Working mode - There are two working modes for the app, that can be chosen with the central switch-button in the GUI
* BeadTrack - track the center of the bead. As output it generate a .txt file organized as follow:

Frame |	X_1 |	Y_1 |	nX_1 |	nY_1 |	Disp |	Ori_Disp |	Radius_1 
----- | --- | --- | ---- | ----- | ----- | --------- | ---------
1.000000 | 98.598571 | 91.951804 | 0.000000 | 0.000000 | 0.000000 | 0.000000 | 20.030492	
2.000000 | 98.389843 | 91.537679 | -0.208728 | -0.414125 | 0.463754 | 0.463754 | 20.046528
... | ... | ... | ... | ... | ... | ... | ... 

The Frame columns is followed by the bead center position (as detected from filling to an ellipsoid). X_1 and Y_1 are the absolute positions in the frame, While the n_X-1 and n_X2

* Rotation - 

Option to display during analysis, to aid in following if the process is done correctly, and plotting the results:
* Display Bead Fitting
* Display Masks
* show inner fitting
* show outer fitting
* show search area
* Preview End_plot

Parameters for analysis:
* T. Levels - use N levels to perform a multilevel image thresholds (using Otsu’s method) - [if bead has high contrast with background, 2 is sufficient]. Create a mask image representing the potential objects (e.g. bead, cells, ...). Then take the largest "circular" object near the center, which most likely is the trapped bead
* Inner C - create the inner circle by scaling radius of detected bead of a factor X (<=1) 
* Outer C - create the inner circle by scaling radius of detected bead of a factor X (>=1) 

% Find the multilevel image thresholds using Otsu's method
    thrs_1 = multithresh(IMG, OPT.T_levels) ;

    % Quantize image using specified quantization levels and output values
    seg_IMG_1 = imquantize(IMG, thrs_1);


![Movie of BoaB under optical trap](../main_version/Movie_and_Images/Movie_Boab.gif)



![GUI of the app](../main_version/Movie_and_Images/Stack_BoaB/BoaB_0100.tif)
![GUI of the app](../main_version/Movie_and_Images/img_Bead_Detection.png)
![GUI of the app](../main_version/Movie_and_Images/img_Set_Rotation.png)


![Plot of R^2 and Radius](../main_version/Movie_and_Images/Plot_Displacement_Position.png)
 
