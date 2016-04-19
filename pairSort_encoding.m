clear; clc;

%setting experiment details
header.expname = 'Space Dog';
header.expvers = 3; %version with ordinal pair sorting task (see 00ReadMe)
header.authors = {'Davide Crombie','Chris Martin','Chris Honey','Morgan Barense'};
header.path = pwd;

%setting parameters for display
header.locpars.bgcolor = [255 255 255];
header.locpars.fontface = 'Arial';
header.locpars.fontsize = 24;
header.locpars.fontcolor = [0 0 0];
header.locpars.fixsize = 24;
header.locpars.fixcolor = [0 0 0];

header.testpars.bgcolor = [255 255 255];
header.testpars.fontface = 'Arial';
header.testpars.fontsize = 24;
header.testpars.fontcolor = [0 0 0];
header.testpars.fixsize = 24;
header.testpars.fixcolor = [0 0 0];

%retrieving participant details
disp(' ');
header.subnum = input(sprintf('Subject number (e.g. %d01): ',header.expvers));
header.subini = input('Subject initials (e.g. ab): ','s');
header.subage = input(sprintf('Subject age: '));
header.subgen = input('Subject gender (m | f): ','s');
header.subgro = lower(input('Subject group (a | b): ','s')); %the participant was replayed either A or B blocks
header.subcond = lower(input('Condition (o | s | p | n): ','s')); %the participant saw ordered, scrambled, or preplay replays, or no replay
header.subtest = lower(input('Test order (s | f): ','s')); %the participant is tested with sorting task first or free recall first
disp(' ');
disp(sprintf('Subject number: %d',header.subnum)); %confirmation of above inputs
disp(sprintf('Subject initials: %s',header.subini));
disp(sprintf('Subject age: %d',header.subage));
disp(sprintf('Subject gender: %s',header.subgen));
disp(sprintf('Subject group: %s',header.subgro));
disp(sprintf('Condition: %s',header.subcond));
disp(sprintf('Test order: %s',header.subtest));
subj_confirm = input('Are these details correct? (y/n): ','s');
if ~strcmp(subj_confirm,'y')
    return;
end

%setting parameters for random number generator
header.group = mod(header.subnum,6) + 1;
rng(header.group,'twister');

%initiating the trial matrix
trial_matrix = [];

%assigning comparisons for each panel included
for block = 3:24 %comparisons only include blocks 3-24
    panels(:,1) = (1:12) + (12 * (block - 1)); %assigning an absolute value to panels in the block
    if mod(block,4) == 1
        compDists = [6; 9; -3; -12; 3; -24; -6; -3; 6; 9; -9; 24]; %assigning a comparison distance to each panel    
    elseif mod(block,4) == 2
        compDists = [9; -24; -6; 12; 6; 3; -9; 24; -3; -9; -6; 3];
    elseif mod(block,4) == 3
        compDists = [6; 9; -3; -12; 3; 24; -6; -3; 6; 9; -9; -24];
    elseif mod(block,4) == 0
        compDists = [9; 24; -6; 12; 6; 3; -9; -24; -3; -9; -6; 3];
    end
    panels(:,2) = panels(:,1) + compDists; %assigning a panel number to the second panel in each pair
    trial_matrix = [trial_matrix; panels]; %filling the trial matrix wtih comparison pairs
end  

%assigning the ealier panel to the first column and the later panel to the 
%second column, necessary for elimination of repeated comparisons
for row = 1:length(trial_matrix)
  if trial_matrix(row,1) > trial_matrix(row,2)
    temp_1 = trial_matrix(row,1);
    temp_2 = trial_matrix(row,2);
    trial_matrix(row,1) = temp_2;
    trial_matrix(row,2) = temp_1;
  else
    continue
  end
end

%eliminating repeated comparisons
trial_matrix = unique(trial_matrix,'rows');

%shuffling the rows
trial_matrix = trial_matrix(randperm(length(trial_matrix)),:);

%assigning L/ R orientation to pairs
trial_matrix(:,3) = (randi(2,length(trial_matrix),1)) - 1;

%adding colum with trial number
trial_matrix(:,4) = (1:length(trial_matrix));
    
%insert trial matrix into participant header data structure
header.test = trial_matrix;

%saving header data structure
header_path = sprintf('%s/headers/header_s%03d.mat',header.path,header.subnum);
check_header_exist = dir(header_path);
if length(check_header_exist) > 0
    disp(' ');
    disp('EXISTING HEADER FOUND!');
    overwrite_confirm = input('Overwrite? (y/n): ','s');
    if strcmp(overwrite_confirm,'y')
        save(header_path,'header');
        disp(' ');
        disp('Overwrite confirmed. Header saved.');
    end
else
    save(header_path,'header');
    disp(' ');
    disp('Header saved.');
end

%call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%get the screen numbers
screens = Screen('Screens');

%draw to the external screen if avaliable
screenNumber = max(screens);

%define white
white = WhiteIndex(screenNumber);

%open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

%set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%load 27 stimulus sets (27 x 12 = 324 frames) - e.g., a.mat, aR.mat,
%b.mat, bR.mat....
files = dir('*.mat');

for stimSet = 1:length(files)
    eval(['load ' files(stimSet).name '']);
end

%setting replay parameters
rTime = 300; nReps = 12;
repTime = repmat(rTime,1,nReps)';

%open relevant filenames and presentation duration
if header.subgro == 'a' && header.subcond == 'o';
    frames = vertcat(a,b,c,d,cR,e,f,cR,g,h,hR,i,j,hR,k,l,kR,m,n,kR,o,p,pR,q,r,pR,s,t,sR,u,v,sR,w,x,xR,y,z,xR,zz);
    
elseif header.subgro == 'a' && header.subcond == 's';
    
    %shuffle relevant rows
    perm = randperm(length(cR)); cR = cR(perm)'; perm = randperm(length(hR))'; hR = hR(perm); perm = randperm(length(kR)); kR = kR(perm)';
    perm = randperm(length(pR)); pR = pR(perm)'; perm = randperm(length(sR))'; sR = sR(perm); perm = randperm(length(xR)); xR = xR(perm)';
    
    for row = 1:length(cR);
        cR{row,2}=300; hR{row,2}=300; kR{row,2}=300; pR{row,2}=300; sR{row,2}=300; xR{row,2}=300;
    end
    
    frames = vertcat(a,b,c,d,cR,e,f,cR,g,h,hR,i,j,hR,k,l,kR,m,n,kR,o,p,pR,q,r,pR,s,t,sR,u,v,sR,w,x,xR,y,z,xR,zz);
    
elseif header.subgro == 'a' && header.subcond == 'p';
    frames = vertcat(cR,hR,kR,pR,sR,xR,cR,hR,kR,pR,sR,xR,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,zz);

elseif header.subgro == 'a' && header.subcond == 'n';
    frames = vertcat(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,zz);
    
elseif header.subgro == 'b' && header.subcond == 'o';
    frames = vertcat(a,b,c,d,dR,e,f,dR,g,h,gR,i,j,gR,k,l,lR,m,n,lR,o,p,oR,q,r,oR,s,t,tR,u,v,tR,w,x,wR,y,z,wR,zz);
    
elseif header.subgro == 'b' && header.subcond == 's';
    
    %shuffle relevant rows
    perm = randperm(length(dR)); dR = dR(perm)'; perm = randperm(length(gR))'; gR = gR(perm); perm = randperm(length(lR)); lR = lR(perm)';
    perm = randperm(length(oR)); oR = oR(perm)'; perm = randperm(length(tR))'; tR = tR(perm); perm = randperm(length(wR)); wR = wR(perm)';
    
    for row = 1:length(cR);
        dR{row,2}=300; gR{row,2}=300; lR{row,2}=300; oR{row,2}=300; tR{row,2}=300; wR{row,2}=300;
    end
    
    frames = vertcat(a,b,c,d,dR,e,f,dR,g,h,gR,i,j,gR,k,l,lR,m,n,lR,o,p,oR,q,r,oR,s,t,tR,u,v,tR,w,x,wR,y,z,wR,zz);

elseif header.subgro == 'b' && header.subcond == 'p';
    frames = vertcat(dR,gR,lR,oR,tR,wR,dR,gR,lR,oR,tR,wR,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,zz);

elseif header.subgro == 'b' && header.subcond == 'n';
    frames = vertcat(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,zz);
end

%presenting the panels
for i = 1:length(frames);
    
    %load an image
    curFrame = imread(frames{i,1});
    
    %make the image into a texture
    imageTexture = Screen('MakeTexture', window, curFrame);
    
    %display image for x seconds.
    if frames{i,2} == 3000;
        
        Screen('DrawTexture', window, imageTexture, [], [], 0); Screen('Flip', window); WaitSecs(3);
        Screen('FillRect', window, white); Screen('Flip', window); WaitSecs(.25);
        
    elseif frames{i,2} == 300;
        Screen('DrawTexture', window, imageTexture, [], [], 0); Screen('Flip', window); WaitSecs(.3);
        Screen('FillRect', window, white); Screen('Flip', window); WaitSecs(.05);
        
    end
end

%clear the screen
sca;

%display message indicating which task to present first
disp(' ');
if header.subtest == 's'
    disp('Present sorting task')
elseif header.subtest == 'f'
    disp('Present free recall')
else
    continue
end






