% =====> MOVIE MAKER <=====================================================

% Import detection file.txt, where all data for the movie is already present

% Reduce the output analysis if necessary to do movies of cropped time lapses:
Frame = [1: 1 : 400] ;
% nX_1 = nX_1([1: 10 : length(Disp)]) ;
% X_1 = X_1([1: 10 : length(Disp)]) ;
% Y_1 = Y_1([1: 10 : length(Disp)]) ;
% nY_1 = nY_1([1: 10 : length(Disp)]) ;
% Radius_1 = Radius_1([1: 10 : length(Disp)]) ;
% Ori_Disp = Ori_Disp([1: 10 : length(Disp)]) ;

delimiters = {'_', '.'};
srcSTART = -1;            % start and end frame of the analysis
srcLAST = -1;
tot_dig = 0;              % total digits in .tif name after the last '_'
theta = 0:pi/60:2*pi;     % array of angle theta from 0 to 2*pi

AxesCol = [.2 .2 .2];
LabelCol = [.2 .2 .2];
TxtSize = 18;

% Access stack folder and index all the file inside that folder
[PathName, FoldName]  = fileparts(uigetdir) ;
srcFiles = dir([PathName '/' FoldName]);

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


Len = length(Ori_Disp);     % Length of movie and detection
fps = 75 ;                  % frame rate of the movie acquisition
time = Frame./fps;          % time in fps
figure('Position', [100 300 1200 800]); 


for ff = srcSTART : srcLAST     
    % Define .tif filename and number   
    N_digits = length(num2str(ff)); 
    N_zeros = repmat('0', [1, 5 - N_digits]);  
    filesave_tif = ['G:\Jenal_Lab_Data\Lab Members Data\Matteo\Movie_170621_01 - version_2 - 75 fps\Mv_' N_zeros num2str(ff) '.tif'];
       
    IMGname = [file_Prefix '_' N_zeros num2str(ff+(srcSTART-1)) '.tif'];
    IMG =  (imread([PathName '/' FoldName '/' IMGname]));
    
% ---> show the BF frame and detection <----------------------------------- 
    clf(1);
    subplot(5,1, [1 2 3]);     axis equal;     hold on;
    % imshow(imadjust(imread(filename)))
    imshow(IMG, [min(min(IMG)), max(max(IMG))] , 'InitialMagnification',100) ;
    % calc the bead detection circle coordinates and plot it
    xs = Radius_1(ff) * cos(theta) + X_1(ff);
    ys = Radius_1(ff) * sin(theta) + Y_1(ff);
    plot(xs, ys, '-', 'Color', [0.4 0.75 1], 'LineWidth', 2);
% % % % % %     % calc "SEARCH" circles coordinates and plot them
% % % % % %     xs = (Radius_1(ff)*0.8) * cos(theta) + X_1(ff);
% % % % % %     ys = (Radius_1(ff)*0.8) * sin(theta) + Y_1(ff);
% % % % % %     plot(xs, ys, '--y', 'LineWidth', 1.25);
% % % % % %     xs = (Radius_1(ff)*1.2) * cos(theta) + X_1(ff);
% % % % % %     ys = (Radius_1(ff)*1.2) * sin(theta) + Y_1(ff);
% % % % % %     plot(xs, ys, '--y', 'LineWidth', 1.25);
    
    % plot line od displacement from OT-center to Bead-center
    plot( [X_1(ff) X_1(2)], [Y_1(ff) Y_1(2)], '.-', 'Color',  [.7 .1 .0] ,...
           'LineWidth', 1.5, 'MarkerSize', 10);
    
    
% ---> show displacement <------------------------------------------------- 
    subplot(5,1, [4 5 ]);     hold on;
    tw = [srcSTART : ff] ;
    pxum = 15.14;
    plot( tw, -nX_1(srcSTART : ff) ./pxum, ':', 'Color', [.0 .7 .0], 'LineWidth', 1.5 );
    plot( tw, -nY_1(srcSTART : ff) ./pxum, ':', 'Color', [.0 .6 .9], 'LineWidth', 1.5 );
    plot( tw, Ori_Disp(srcSTART : ff) ./pxum ,  'Color', [.7 .1 .0], 'LineWidth', 2.2 );
    % plot baseline at zero
    plot([0,Len],[0,0], '--', 'Color',[.5 .5 .5], 'LineWidth', 0.5);
    
    ax = gca;                  
    ax.FontSize = TxtSize;     ax.Box = 'on';
    ax.XColor = AxesCol;       ax.YColor = AxesCol;
    ax.TickDir = 'out';        ax.LineWidth = 2;

    xlabel('time [s]',  'Color',LabelCol, 'FontSize', TxtSize );
    ylabel('\Deltadisp [\mum]', 'Color',LabelCol, 'FontSize', TxtSize );
    
    ax.YLim = [-0.5 2];
    ax.YTick = [-0.5 : 0.5 : 2]; 
    ax.YTickLabels = [-0.5 : 0.5 : 2];
    
    % Choose XLIM so that it moves with the movie
    if ff - srcSTART <= 50    
        ax.XLim = [0 , 80];
    elseif srcLAST - ff <= 30 
        ax.XLim = [srcLAST-80 , srcLAST];
    else
        ax.XLim = [ff-50 , ff+30]
    end    
    ax.XTick = [0: 37.5 : Frame(end)]; 
    ax.XTickLabels = [0: 37.5 : Frame(end)]./fps;
    
    % For last frame, show all displacement graph
    if ff == srcLAST
        ax.XLim = [0 , srcLAST]
        ax.XTick = [0: 22.5*10 : Frame(end)];
        ax.XTickLabels = [0: 22.5*10 : Frame(end)]./fps;
    end 
       
    
    set(gcf, 'Color', [1,1,1]);

    
    saveas(gcf, filesave_tif )
    pause(0.0001)
end

    
% =========================================================================

    