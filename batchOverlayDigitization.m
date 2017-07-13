function [] = batchOverlayDigitization(infolder,camera_names,varargin)
% 
% 
% 
% Dinesh Natesan
% 11th July 2017

%% Handle inputs
% only want 3 optional inputs at most
numargs = length(varargin);
if numargs > 3
    error('batchOverlayDigitization:TooManyInputs', ...
        'requires at most 3 optional inputs');
end

% set defaults for optional inputs
% recursive=yes, avifile=yes, quality=100
optargs = {1 1 100};    

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:numargs) = varargin;

%% Obtain video files
% Video file extension
if optargs{2}
    vid_file_ext = '.avi';
else
    vid_file_ext = '.cine';
end
% List all Video files in the directory
if optargs{1}
    videofiles = dir(fullfile(infolder,sprintf('**/*%s',vid_file_ext)));
    csvfiles = dir(fullfile(infolder,'**/*xypts.csv'));
else
    videofiles = dir(fullfile(infolder,sprintf('*%s',vid_file_ext)));
    csvfiles = dir(fullfile(infolder,'*xypts.csv'));
end

% Extract video names
videofiles = struct2cell(videofiles)';
videonames = fullfile(videofiles(:,2), videofiles(:,1));
videofilenames = cellfun(@(x) x(1:end-length(vid_file_ext)),...
    videofiles(:,1),'UniformOutput',false);

% Extract csv file names (xypts)
csvfiles = struct2cell(csvfiles)';
csvfilenames = cellfun(@(x) x(1:end-4-length('xypts')),...
    csvfiles(:,1),'UniformOutput',false);

% Sort based on camera
if length(camera_names)>1
    %
    cam1_files = find(~cellfun(@isempty, strfind(videonames,camera_names(1))));
    infiles = [];
    outfiles = [];
    csvs = [];

    % See if a similar file with different camera name is found 
    for i=1:length(cam1_files)
        % Create a cell for temp storage
        temp_vid = cell(1,length(camera_names));
        temp_vid(1) = videonames(cam1_files(i));        
        temp_camnames = strrep(videofilenames(cam1_files(i)),...
            camera_names{1},'');
        
        for j=2:length(camera_names)
            altcam_ind = ismember(videonames,...
                strrep(videonames(cam1_files(i)),...
                camera_names{1},camera_names{j}));            
            if sum(altcam_ind)==1
                temp_vid(j) = videonames(altcam_ind);      
            end        
        end
        
        % Check if a file was found for all videos
        if all(~cellfun(@isempty, temp_vid))
            % Obtain best CSV match
            match_score = cellfun(...
                @(x) sum(temp_camnames==x)/length(temp_camnames),...
                csvfilenames, 'UniformOutput',false);
            [~,match_ind] = max(match_score);
            
            % Check if directories match
            if strcmp(csvfiles(match_ind,2),videofiles(cam1_files(i),2))
                % Assign infiles, outfiles and csvfiles
                infiles = [infiles;temp_vid]; %#ok<AGROW>
                outfiles = [outfiles;...
                    strrep(videonames(cam1_files(i)),camera_names{1},{'Digitized'})]; %#ok<AGROW>
                csvs = [csvs;...
                    fullfile(csvfiles(match_ind,2),csvfiles(match_ind,1))];
            end
        end
    end  
    
else
    selected_ind = ~cellfun(@isempty, strfind(videonames,camera_names));
    infiles = videonames(selected_ind);
    outfiles = strrep(videonames(selected_ind),camera_names,{'Digitized'});    
end



end