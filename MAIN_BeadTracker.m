function MAIN_BeadTracker(app)
%--------------------------------------------------------------------------    
% BEAD TRACKER main function
%--------------------------------------------------------------------------
% The function is created to track a single bead in a timelapse movie.
% The script use multilevel image thresholds to find the biggest object
% in the frame and then fit its perimeter to a circle.
% There is the option to use a pseudo-Gaussian method, where we delimit two
% rings that encompass the bright difraction ring of the bead and then find
% the highest pixel value in that ring circumference. Those are then used
% to fit in a circle.
% The function, according to proper choises, display the analysis fitting
% and masks created.
%
%
% ... PARAMETERS ..........................................................
% OPT.T_levels      perform threshold with N threshold levels
% OPT.f1            decrease bead "Dark" circle of F%
% OPT.f2            increase bead "Dark" circle of F%
% [ those are then used to create two circles and delimit the area where to 
%   search for the bright difraction ring ]
% OPT.Range         frame range in which to perform the analysis
% OPT.Exp_name      name of the experiment to asign at the .txt output file
%
%
% ... other INPUTs ........................................................
% OPT.Disp_Masks
% OPT.Disp_Bea
% OPT.Disp_Dark_C
% OPT.Disp_Light_C 
% OPT.Disp_Search_C
% OPT.Method_2
%
%
%--------------------------------------------------------------------------
% MIT License
% Copyright (c) 2017 - Matteo Sangermani
%--------------------------------------------------------------------------
clc;    clearvars -except OPT app;

global OPT;

delimiters = {'_', '.'};
srcSTART = -1;            % start and end frame of the analysis
srcLAST = -1;
tot_dig = 0;              % total digits in .tif name after the last '_'
theta = 0:pi/60:2*pi;     % array of angle theta from 0 to 2*pi
rr = 1;                   % row counter of .txt file

% Access stack folder and index all the file inside that folder
% [PathName, FoldName]  = fileparts(uigetdir) ;
% OPT.path = PathName ;
% OPT.fold = FoldName ; 
srcFiles = dir([OPT.path '/' OPT.fold]);

% Determine name of output file and initialize the first row
if isempty(OPT.Exp_name)
    filename_txt = [ OPT.path '/Track_' OPT.fold '.txt'];
else
    filename_txt = [ OPT.path '/Track_' OPT.Exp_name '.txt'];
end
file_C = fopen(filename_txt, 'w+');   
if  OPT.Method_2 == 1
    fprintf( file_C, 'Frame \tX_1 \tY_1 \tnX_1 \tnY_1 \tDisp \tOri_Disp \tRadius_1 \t');
    fprintf( file_C,       '\tX_2 \tY_2 \tnX_2 \tnY_2 \tDisp \tOri_Disp \tRadius_2 \n'  );
else
    fprintf( file_C, 'Frame \tX_1 \tY_1 \tnX_1 \tnY_1 \tDisp \tOri_Disp \tRadius_1 \n' );
end



% RANGE OF ANALYSIS: find the range of the frames and user defined range
% Sort the names of all the files in the folder
cell_srcFiles = struct2cell(srcFiles);
% srcFiles_2 = srcFiles(~[cell_srcFiles{5,:}]); 

[sort_name] = sort( cell_srcFiles(1,:) );
% The last in the list is the last frame. Take its number
file_Name = strsplit(sort_name{end} , delimiters); 
% Create prefix name of image files, by joining strings up to the last '_' separation.
file_Prefix = strsplit(sort_name{end} , '_');
file_Prefix = file_Prefix(1:end-1);
file_Prefix = strjoin(file_Prefix , '_');

fr_num  = file_Name{end-1};
tot_dig = length(fr_num);           % Count number of digits
srcLAST = str2num(fr_num);          % Assign last frame number
% Assign the first frame and its number: it can only be 1
srcSTART = 1;
    
if ~strcmp( OPT.Range , 'S:E')
    RR = strsplit(OPT.Range,{':'});
    if str2num(RR{1}) > str2num(RR{2})  ||  length(RR) ~= 2  || ...
    isstring(str2num(RR{1}))  ||  isstring(str2num(RR{2}))
      app.TextOut.Value = sprintf('%s', ['Invalid Range!!!']);
      OPT.ERROR = 1;
      return
    end
    if str2num(RR{2}) > srcLAST || str2num(RR{2}) < srcSTART
      app.TextOut.Value = sprintf('%s', ['Range exceed limits !!!']);
      OPT.ERROR = 1;
      return
    end
    srcSTART = str2num(RR{1}); 
    srcLAST  = str2num(RR{2});
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ANALYSIS ----------------------------------------------------------------
for ff = srcSTART : srcLAST     
    
    if OPT.STOP == 1;
        OPT.STOP = 1;
        return
    end
    
    % Reset the variables
    idx_XY_1 = [];    peri_XY_1 = [];    
    idx_XY_2 = [];    peri_XY_2 = [];
    
    N_dig = length(num2str(ff)); 
    N_null = repmat('0', [1, tot_dig - N_dig]);

    IMGname = [file_Prefix '_' N_null num2str(ff+(srcSTART-1)) '.tif'];
    IMG =  (imread([OPT.path '/' OPT.fold '/' IMGname]));
 
% ----> FIRST THRES: dark inner core <-------------------------------------
    % Find the multilevel image thresholds using Otsu's method
    thrs_1 = multithresh(IMG, OPT.T_levels) ;

    % Quantize image using specified quantization levels and output values
    seg_IMG_1 = imquantize(IMG, thrs_1);

    % Create a mask of all detected objects with the given OPT.T_levels threshold
    Mask_1 = seg_IMG_1 ;
    Mask_1( seg_IMG_1 ~= 1) = 0 ;
    
    % Find connected components in the Bead_Mask
    Mask_1 = imfill(Mask_1,'holes');
    temp = bwconncomp(Mask_1, 4);

    % Find the largest component in the mask, it should be the bead, and save
    % linear coordintes (idx_LIN) and as xy-coord (idx_XY). 
    % Then create a mask of the bead (Mask_Bd_1)
    Len_idx_1 = cellfun(@length, temp.PixelIdxList);
    idx_LIN_1 = temp.PixelIdxList{ find(Len_idx_1 == max(Len_idx_1)) };
    [idx_XY_1(:,2), idx_XY_1(:,1)] = ind2sub(temp.ImageSize, idx_LIN_1);
    Mask_Bd_1 = zeros(temp.ImageSize);
    Mask_Bd_1(idx_LIN_1) = 1;

    % Find the Perimeter of the bead and its coordinates
    Mask_Bd_Peri_1 = bwperim(Mask_Bd_1);
    [peri_XY_1(:,2), peri_XY_1(:,1)] = ind2sub(temp.ImageSize, find(Mask_Bd_Peri_1 == 1)) ;

    % Fit the bead's perimeter coordinate into a circle function and find center.
    [cntr, Fit_R_1(ff) ] = fit_circle(peri_XY_1, 'linear');
    Fit_C_1(ff,:) = cntr';  
    
    
% ----> SECOND THRES: light outer ring <-----------------------------------   
    if OPT.Method_2 == 1
        % Define the outer and inner search circle that enclose the light difraction
        % pattern of the bead    
        x_sIn = OPT.f1 *Fit_R_1(ff) * cos(theta) + Fit_C_1(ff,1);
        y_sIn = OPT.f1 *Fit_R_1(ff) * sin(theta) + Fit_C_1(ff,2);    
        x_sOut = OPT.f2 *Fit_R_1(ff) * cos(theta) + Fit_C_1(ff,1);
        y_sOut = OPT.f2 *Fit_R_1(ff) * sin(theta) + Fit_C_1(ff,2);

        % Create radial profile lines between the two search circles. Save the
        % variables G (Px values), and line coordinates (Gx and Gy)
        G = {};     Gx = {};     Gy = {};     Cxy = [];
        for jj = 1 : length(x_sIn)
            [Gx{jj},Gy{jj}, G{jj}] = improfile(IMG, [x_sIn(jj); x_sOut(jj)], [y_sIn(jj); y_sOut(jj)]);
        end

        % Go through each line profile and search max (peak) value and store
        % its coordinates in Cxy
        for jj = 1 : length(x_sIn)
            Px_peak = find( G{jj} == max(G{jj})) ;
            if length(Px_peak) == 1
                Cxy(jj,1) = Gx{jj}(Px_peak) ;
                Cxy(jj,2) = Gy{jj}(Px_peak) ;   
            % if there are >2 equal values, then take the mean for the coordinates    
            elseif length(Px_peak) > 1
                Cxy(jj,1) = mean(Gx{jj}(Px_peak)) ;
                Cxy(jj,2) = mean(Gy{jj}(Px_peak)) ;
            end
        end
        
        % Fit the Cxy coordinate into a circle function and find circle center.
        [cntr, Fit_R_2(ff) ] = fit_circle(Cxy, 'linear');
        Fit_C_2(ff,:) = cntr'; 
    end
    
  
% ----> DISPLAY ANALYSIS <-------------------------------------------------
    if OPT.Disp_Masks == 1
        if OPT.Disp_Bead == 1 
            col = 3
        else
            col = 2;
        end
        fig1 = figure(1);
%         fig1.Position(1:2) = [50 500];
        hold on;
%         subplot(1,col,1);      
        imshow(seg_IMG_1,[1,OPT.T_levels+1]) ;
                               title('Raw "Quanta" detection');                                  
%         subplot(1,col,2);      imshow(Mask_Bd_1);
%                                title('Bead  and Perimeter'); 
%                                 
        if OPT.Disp_Bead == 1                                 
            subplot(1,col,3);         imshow(IMG);            hold on;
            title('Bright Field and circle Fitting');
            % Plot the search ring 
            if OPT.Disp_Search_C == 1  &&  OPT.Method_2 == 1
                plot( x_sIn, y_sIn, '--y');    
                plot(x_sOut, y_sOut, '--y');
            end

            % Define and draw the fitted circles
            if OPT.Disp_Dark_C == 1
                xs_1 = Fit_R_1(ff) * cos(theta) + Fit_C_1(ff,1);
                ys_1 = Fit_R_1(ff) * sin(theta) + Fit_C_1(ff,2);
                plot(xs_1, ys_1, '-', 'Color', [0.4 0.75 1], 'LineWidth', 1.5);
                plot(Fit_C_1(ff,1), Fit_C_1(ff,2), '.', 'Color', [0.4 0.75 1], 'MarkerSize', 15); 
            end

            if OPT.Disp_Light_C == 1  &&  OPT.Method_2 == 1
                xs_2 = Fit_R_2(ff) * cos(theta) + Fit_C_2(ff,1);
                ys_2 = Fit_R_2(ff) * sin(theta) + Fit_C_2(ff,2);
                plot(xs_2, ys_2, '-r', 'LineWidth', 1.5);
                plot(Fit_C_2(ff,1), Fit_C_2(ff,2), '.r', 'MarkerSize', 15);
            end
        end
    end
    
    if OPT.Disp_Bead == 1  &&  OPT.Disp_Masks == 0
        fig2 = figure(2);   
        fig2.Position(1:2) = [50 100];
        
        imshow(IMG);            hold on;
        title('Bright Field and circle Fitting');
        % Plot the search ring 
        if OPT.Disp_Search_C == 1  &&  OPT.Method_2 == 1
            plot( x_sIn, y_sIn, '--y');    
            plot(x_sOut, y_sOut, '--y');
        end
        
        % Define and draw the fitted circles
        if OPT.Disp_Dark_C == 1
            xs_1 = Fit_R_1(ff) * cos(theta) + Fit_C_1(ff,1);
            ys_1 = Fit_R_1(ff) * sin(theta) + Fit_C_1(ff,2);
            plot(xs_1, ys_1, '-', 'Color', [0.4 0.75 1], 'LineWidth', 1.5);
            plot(Fit_C_1(ff,1), Fit_C_1(ff,2), '.', 'Color', [0.4 0.75 1], 'MarkerSize', 15); 
        end
        
        if OPT.Disp_Light_C == 1  &&  OPT.Method_2 == 1
            xs_2 = Fit_R_2(ff) * cos(theta) + Fit_C_2(ff,1);
            ys_2 = Fit_R_2(ff) * sin(theta) + Fit_C_2(ff,2);
            plot(xs_2, ys_2, '-r', 'LineWidth', 1.5);
            plot(Fit_C_2(ff,1), Fit_C_2(ff,2), '.r', 'MarkerSize', 15);
        end
    end    
    
    
% ----> SAVE DATA in txt file <--------------------------------------------
    Mat(rr,1) = ff;     % Frame number   
    % XY coord and R^2, raw and normalized
    Mat(rr,2) = Fit_C_1(ff,1);        Mat(rr,3) = Fit_C_1(ff,2);
    if    ff ~= srcSTART
        Mat(rr,4) = Fit_C_1(ff,1)-Fit_C_1(1,1);        Mat(rr,5) = Fit_C_1(ff,2)-Fit_C_1(1,2);
        Mat(rr,6) = sqrt((Fit_C_1(ff,1) -Fit_C_1(ff-1,1))^2 + (Fit_C_1(ff,2) -Fit_C_1(ff-1,2))^2);  
        Mat(rr,7) = sqrt((Fit_C_1(ff,1) -Fit_C_1(1,1))^2 + (Fit_C_1(ff,2) -Fit_C_1(1,2))^2);  
    elseif ff == srcSTART
        Mat(rr,4) = 0;        Mat(rr,5) = 0;
        Mat(rr,6) = 0 ;
        Mat(rr,7) = 0 ;
    end
    Mat(rr,8) = Fit_R_1(ff) ;
            
    if  OPT.Method_2 == 1
        Mat(rr,10) = Fit_C_2(ff,1);        Mat(rr,11) = Fit_C_2(ff,2);
        if    ff ~= srcSTART
            Mat(rr,12) = Fit_C_2(ff,1)-Fit_C_2(1,1);        Mat(rr,13) = Fit_C_2(ff,2)-Fit_C_2(1,2);
            Mat(rr,14) = sqrt((Fit_C_2(ff,1) -Fit_C_2(ff-1,1))^2 + (Fit_C_2(ff,2) -Fit_C_2(ff-1,2))^2);  
            Mat(rr,15) = sqrt((Fit_C_2(ff,1) -Fit_C_2(1,1))^2 + (Fit_C_2(ff,2) -Fit_C_2(1,2))^2);  
        elseif ff == srcSTART
            Mat(rr,12) = 0;        Mat(rr,13) = 0;
            Mat(rr,14) = 0 ;
            Mat(rr,15) = 0 ;
        end 
        Mat(rr,16) = Fit_R_2(ff) ; 
    end    
    % Write in the .txt file and show status of analysis
    fprintf( file_C , '%f\t', Mat(rr,:) );
    fprintf( file_C , '\n');
     
    pause(0.001);   
    app.TextOut.Value = sprintf('%s', ['Frame ' num2str(rr) ' of ' num2str(srcLAST-srcSTART+1)] );                 
    rr = rr +1; 
    
end


% ----> DISPLAY PREVIEW ANALYSIS <-----------------------------------------
if OPT.PreviewPlot == 1
    Preview_Plot(Mat)
end
    
fclose(file_C) ;

end




% =========================================================================
function Preview_Plot(Mat_Dat)
    global OPT;
    hnd.figure1 = figure(3);
    clf(3);    
    hnd.figure1.Position = [400 50 1400 350];

    subplot(2,1,1);         hold on;
                              plot(Mat_Dat(:,1), Mat_Dat(:,6), 'Color', [0.4 0.75 1]);   
    if  OPT.Method_2 == 1;    plot(Mat_Dat(:,1), Mat_Dat(:,14));      end
    hnd.axes = gca;
    hnd.axes.XLim = [min(Mat_Dat(:,1)), max(Mat_Dat(:,1))];
    hnd.axes.TickDir = 'out';
    hnd.axes.XColor = [.3 .3 .3];        hnd.axes.YColor = [.3 .3 .3];
    ylabel('Dispacement R^2');

    subplot(2,1,2);         hold on;
                              plot(Mat_Dat(:,1), Mat_Dat(:,8), 'Color', [0.4 0.75 1]);   
    if  OPT.Method_2 == 1;    plot(Mat_Dat(:,1), Mat_Dat(:,16));      end
    
    hnd.axes = gca;
    hnd.axes.XLim = [min(Mat_Dat(:,1)), max(Mat_Dat(:,1))];
    hnd.axes.TickDir = 'out';
    hnd.axes.XColor = [.3 .3 .3];        hnd.axes.YColor = [.3 .3 .3];
    ylabel('Radius');
end
