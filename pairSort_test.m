function behav = pairSort_test(header)

    nTrials = length(header.test);

    %initializing variables in the bhav data structure for future input
    behav.resp = NaN(nTrials,1); %will be filled with the panel selection for each trial
    behav.rt = NaN(nTrials,1); %will be filled with the rxn time (RT) for each trial

    %getting window parameters and finding the center of the screen
    [ptw ptdims] = Screen('OpenWindow',0,header.testpars.bgcolor);
    Screen('BlendFunction',ptw,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    %setting font
    Screen(ptw,'TextFont',header.testpars.fontface);

    %setting cursor type
    ShowCursor('Hand');

    %displaying instructions until trigger
    Screen(ptw,'FillRect',header.testpars.bgcolor);
    instructtext = 'Please indicate which panel came first by pressing the Z (left) or M (right) key'; %add 'Press space to continue'
    Screen(ptw,'TextSize',header.testpars.fontsize);
    DrawFormattedText(ptw,instructtext,'center','center',header.testpars.fontcolor);
    Screen(ptw,'Flip');

    %waiting for trigger
    check_trigger = 0;
    while check_trigger == 0
        [keyIsDown,secs,keyCode] = KbCheck(-1); % -1 indicates directs KbCheck to query all keyboard devices
        check_trigger = strcmp(KbName(keyCode),'space');
    end

    %displaying ready screen for 2 seconds
    Screen(ptw,'FillRect',header.testpars.bgcolor);
    readytext = 'Ready';
    Screen(ptw,'TextSize',header.testpars.fontsize);
    DrawFormattedText(ptw,readytext,'center','center',header.testpars.fontcolor);
    Screen(ptw,'Flip');
    pause(2);

    %getting experiment start time
    startTime = GetSecs;
    behav.beginTime = fix(clock);

    %displaying the comparison pair on each trial and recording the response
    for trial = 1:nTrials

        %loading the images
        if header.test(trial,3) == 0 %L or R presentation was shuffled in pairSort_encoding
            stimPath_1 = sprintf('%s/images/%d.png',header.path,header.test(trial,1));
            stimImg_1 = imread(stimPath_1);
            shuffledImg_1 = imresize(stimImg_1,[300 300]);

            stimPath_2 = sprintf('%s/images/%d.png',header.path,header.test(trial,2));
            stimImg_2 = imread(stimPath_2);
            shuffledImg_2 = imresize(stimImg_2,[300 300]);
        elseif header.test(trial,3) == 1
            stimPath_1 = sprintf('%s/images/%d.png',header.path,header.test(trial,2));
            stimImg_1 = imread(stimPath_1);
            shuffledImg_1 = imresize(stimImg_1,[300 300]);

            stimPath_2 = sprintf('%s/images/%d.png',header.path,header.test(trial,1));
            stimImg_2 = imread(stimPath_2);
            shuffledImg_2 = imresize(stimImg_2,[300 300]);
        end

        %filling screen with the set background colour
        Screen(ptw,'FillRect',header.testpars.bgcolor);

        trial_start = GetSecs; %getting trial start time for RT calculation

        check_trial_confirm = 0; %will be changed to 1 when a panel is selected
        while check_trial_confirm == 0

            %calculating image to render
            screenImg = ones(768,1024,3).*255;

            %drawing each image
            imgx_1 = 188 + (1:300);
            imgy_1 = 234 + (1:300);
            imgpix_1 = shuffledImg_1;
            imgpix_1([1:2 (300 + [-1 0])],:,:) = 128;
            imgpix_1(:,[1:2 (300 + [-1 0])],:) = 128;

            screenImg(imgy_1,imgx_1,:) = imgpix_1;

            imgx_2 = 536 + (1:300);
            imgy_2 = 234 + (1:300);
            imgpix_2 = shuffledImg_2;
            imgpix_2([1:2 (300 + [-1 0])],:,:) = 128;
            imgpix_2(:,[1:2 (300 + [-1 0])],:) = 128;

            screenImg(imgy_2,imgx_2,:) = imgpix_2;

            screenImg(700:768,1:1024,:) = 255;

            %updating screen to display the image pair
            screenImg_final = imresize(screenImg,ptdims([4 3]));
            screenTex = Screen(ptw,'MakeTexture',screenImg_final);
            Screen(ptw,'DrawTexture',screenTex);
            Screen(ptw,'TextSize',header.testpars.fixsize);
            Screen(ptw,'Flip');

            %collecting the response
            [keyIsDown,secs,keyCode] = KbCheck(-1);
            if strcmp(KbName(keyCode),'z')
                check_trial_confirm = strcmp(KbName(keyCode),'z');
                behav.resp(trial,2) = 1; %storing panel choice (1 = left)
                behav.rt(trial,2) = GetSecs - trial_start; %storing trial RT
            elseif strcmp(KbName(keyCode),'m')
                check_trial_confirm = strcmp(KbName(keyCode),'m');
                behav.resp(trial,2) = 0; %(0 = right)
                behav.rt(trial,2) = GetSecs - trial_start;
            end
        end

        Screen('Close');

        %preseting instructions to move on to next trial
        Screen(ptw,'FillRect',header.testpars.bgcolor);
        nexttext = 'Please press space for the next trial.';
        Screen(ptw,'TextSize',header.testpars.fontsize);
        DrawFormattedText(ptw,nexttext,'center','center',header.testpars.fontcolor);
        Screen(ptw,'Flip');

        %waiting for the trigger
        check_trigger = 0;
        while check_trigger == 0
            [keyIsDown,secs,keyCode] = KbCheck(-1);
            check_trigger = strcmp(KbName(keyCode),'space');
        end

    end

    %presenting instruction that experiment is complete
    Screen(ptw,'FillRect',header.testpars.bgcolor);
    nexttext = 'Experiment Complete. Press Space To Exit.';
    Screen(ptw,'TextSize',header.testpars.fontsize);
    DrawFormattedText(ptw,nexttext,'center','center',header.testpars.fontcolor);
    Screen(ptw,'Flip');

    %waiting for trigger
    check_trigger = 0;
    while check_trigger == 0
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        check_trigger = strcmp(KbName(keyCode),'space');
end

%closing screen
Screen('CloseAll');

%saving responses in participant data structure
behav.duration = GetSecs - startTime;
behav.endTime = fix(clock);
behav.parameters = pars;
data_path = sprintf('%s/behav/behav_s%03d.mat',header.path,header.subnum);
check_data_exist = dir(data_path);
if length(check_data_exist) > 0
    disp(' ');
    disp('EXISTING DATA FOUND!');
    overwrite_confirm = input('Overwrite? (y/n): ','s');
    if strcmp(overwrite_confirm,'y')
        save(data_path,'behav');
        disp(' ');
        disp('Overwrite confirmed. Data saved.');
    end
else
    save(data_path,'behav');
    disp(' ');
    disp('Data saved.');
end