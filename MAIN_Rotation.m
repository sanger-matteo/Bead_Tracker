function MAIN_BeadTracker(app)
%--------------------------------------------------------------------------    
% ROTATION main function
%--------------------------------------------------------------------------
% Describe an ellipse/circle object around the bead. Then the algorithm
% will take the values for all the pixels that describe the ellipse and
% save them in a linear array. This process is done for all frames and save
% as e_DATA.txt
% The algorithm also does the same for the "vertices" describing the ellipse
% resulting in a more condensed data (saved as v_DATA.txt)
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

% Access stack folder and index all the file inside that folder
% [PathName, FoldName]  = fileparts(uigetdir) ;
% OPT.path = PathName ;
% OPT.fold = FoldName ; 
srcFiles = dir([OPT.path '/' OPT.fold]);


% RANGE OF ANALYSIS: find the range of the frames and user defined range
% Sort the names of all the files in the folder
cell_srcFiles = struct2cell(srcFiles);

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

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% FIRST FRAME : analysed independently :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

N_null = repmat('0', [1, tot_dig - length(num2str(srcSTART)) ]);
IMGname = [file_Prefix '_' N_null num2str(srcSTART) '.tif'];
firstIMG = [ OPT.path '/' OPT.fold '/' IMGname ] ;
im_A = imread(firstIMG);

% Select manually the OBJ to use as reference:
% -------------------------------------------------------------------------
% Place an ellipse object in first frame of movie. Then create a mask of 
% the ellipse perimeter.
fg2 = figure(2);  clf(2);
imshow(im_A) ;        
hnd = imellipse ;                   % draw ellipse
vert = wait(hnd) ;                  % allow resize, and wait untill doubleclick to continue
row = round(vert(:,2));
col = round(vert(:,1));

% Find the 1+8-neighborings pixels of the vertexes:
Row_9 = [ row   row-1,  row-1,  row-1,  row  ,...
                row,    row+1,  row+1,  row+1,  ];
Col_9 = [ col   col-1,  col,    col,    col-1 ,...
                col+1,  col-1,  col,    col+1 ]; 
            
% create the binary perimeted mask of the ellipse            
Mask_elip = bwperim(createMask(hnd));     
% Extract the pixel coordinates subscripts and indexes
% bwboundaries --> start from one pixel and goes from one to the next
%                  neighbour describing a circle of the perimeter.If we 
%                  plot in microbeTracker we then have circular line.
% NB : the coordinates are given as [Y,X], opposite order than usual        
stats = bwboundaries(Mask_elip,'noholes');
e_sub(:,1) = stats{1}(:,2) ;
e_sub(:,2) = stats{1}(:,1) ;
e_ind = sub2ind(size(Mask_elip), e_sub(:,2), e_sub(:,1)) ;
            

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ALL FRAMES +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
jj=1;   % counter for saving data
for ff = srcSTART+1 : srcLAST-1
    
    N_dig = length(num2str(ff)); 
    N_null = repmat('0', [1, tot_dig - N_dig]);

    IMGname = [file_Prefix '_' N_null num2str(ff+(srcSTART-1)) '.tif'];
    im_A =  (imread([OPT.path '/' OPT.fold '/' IMGname]));

    % ------------------------------------------------------------------------------------------------------
    eDATA(ff,:) = im_A(e_ind)';
    
    % Save value of the mean of the 1+8-neighboring pixels
    vDATA(ff,:) = mean(im_A( sub2ind(size(im_A), Row_9, Col_9) ), 2);

    jj = jj+1 ;
    app.TextOut.Value = sprintf('%s', ['Fr: ' num2str(ff) ' of ' num2str(srcLAST-srcSTART+1)] );                 

end

% Save results in .txt files
dlmwrite( [OPT.path '/perimeter_Circle.txt'] , eDATA, 'delimiter', '\t')
dlmwrite( [OPT.path '/vertex_Circle.txt'] , vDATA, 'delimiter', '\t')




