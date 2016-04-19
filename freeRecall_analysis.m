clear;
numPart = input(sprintf('Number of participants: '));

%%%% Variable Dictionary %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Updates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each variable should be an array within the group structure
% 

%initializing group-wise variables
group.non_prop = [];
group.non_wc = [];
group.non_wc_sum = [];
group.non_prop_a = [];
group.non_prop_b = [];
group.non_prop_c = [];
group.non_prop_cpr = [];
group.non_wc_a = [];
group.non_wc_b = [];
group.non_wc_c = [];
group.non_wc_cpr = [];

group.rep_prop = [];
group.rep_wc = [];
group.rep_wc_sum = [];
group.rep_prop_a = [];
group.rep_prop_b = [];
group.rep_prop_c = [];
group.rep_prop_cpr = [];
group.rep_wc_a = [];
group.rep_wc_b = [];
group.rep_wc_c = [];
group.rep_wc_cpr = [];
group.rep_prop_r = [];
group.rep_prop_n = [];
group.rep_wc_r = [];
group.rep_wc_n = [];

group.pre_prop = [];
group.pre_wc = [];
group.pre_wc_sum = [];
group.pre_prop_a = [];
group.pre_prop_b = [];
group.pre_prop_c = [];
group.pre_prop_cpr = [];
group.pre_wc_a = [];
group.pre_wc_b = [];
group.pre_wc_c = [];
group.pre_wc_cpr = [];
group.pre_prop_r = [];
group.pre_prop_n = [];
group.pre_wc_r = [];
group.pre_wc_n = [];

for part = 1:numPart
    
    %loading participant data
    partID = 300 + part;
    path = pwd;
    dataFile = sprintf('%s/behav/spaceDog_test_s%d.mat',path,partID);
    check_data_exist = dir(dataFile);
    if length(check_data_exist) > 0
        load(dataFile)
        headerFile = sprintf('%s/headers/spaceDog_s%d.mat',path,partID);
        load(headerFile)
    else
        continue
    end
    
    if strcmp(header.subgro,'a')
        partGroup = 0;
    else
        partGroup = 1;
    end
    
    %assigning blocks to a group (0 = A, 1 = B, 2 = C)
    for row = 1:length(data.fr_matrix)
        if ismember(data.fr_matrix(row,2),[5,6,9,10,13,14,17,18,21,22,25])
            data.fr_matrix(row,3) = 2;
        elseif ismember(data.fr_matrix(row,2),[1,2,26,27]) %special label for initial and final C blocks
            data.fr_matrix(row,3) = 3;
        elseif ismember(data.fr_matrix(row,2),[3,8,11,16,19,24])
            data.fr_matrix(row,3) = 0;
        elseif ismember(data.fr_matrix(row,2),[4,7,12,15,20,23])
            data.fr_matrix(row,3) = 1;
        end
    end
    
    %getting overall word count and proportion
    data.prop = sum(logical(data.fr_matrix(:,4))) / length(data.fr_matrix);
    data.wc_sum = sum(data.fr_matrix(:,4));
    data.wc = sum(data.fr_matrix(:,4)) / sum(logical(data.fr_matrix(:,4)));
    
    %getting group-wise word count and proportion
    data.prop_a = sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 0, 4))) / length(data.fr_matrix(data.fr_matrix(:,3) == 0));
    data.prop_b = sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 1, 4))) / length(data.fr_matrix(data.fr_matrix(:,3) == 1));
    data.prop_c = sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 2, 4))) / length(data.fr_matrix(data.fr_matrix(:,3) == 2));
    data.prop_cpr = sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 3, 4))) / length(data.fr_matrix(data.fr_matrix(:,3) == 3));
    data.wc_a = sum(data.fr_matrix(data.fr_matrix(:,3) == 0, 4)) / sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 0, 4)));
    data.wc_b = sum(data.fr_matrix(data.fr_matrix(:,3) == 1, 4)) / sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 1, 4)));
    data.wc_c = sum(data.fr_matrix(data.fr_matrix(:,3) == 2, 4)) / sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 2, 4)));
    data.wc_cpr = sum(data.fr_matrix(data.fr_matrix(:,3) == 3, 4)) / sum(logical(data.fr_matrix(data.fr_matrix(:,3) == 3, 4)));
    
    %getting replayed and non-replayed word count and proportion
    if strcmp(header.subcond,'o') || strcmp(header.subcond,'p') || strcmp(header.subcond,'s')
        data.prop_r = sum(logical(data.fr_matrix(data.fr_matrix(:,3) == partGroup, 4))) / length(data.fr_matrix(data.fr_matrix(:,3) == partGroup));
        data.prop_n = sum(logical(data.fr_matrix(and(data.fr_matrix(:,3) ~= partGroup, data.fr_matrix(:,3) ~= 3), 4))) / length(data.fr_matrix(and(data.fr_matrix(:,3) ~= partGroup, data.fr_matrix(:,3) ~= 3))); 
        data.wc_r = sum(data.fr_matrix(data.fr_matrix(:,3) == partGroup, 4)) / sum(logical(data.fr_matrix(data.fr_matrix(:,3) == partGroup, 4)));
        data.wc_n = sum(data.fr_matrix(and(data.fr_matrix(:,3) ~= partGroup, data.fr_matrix(:,3) ~= 3), 4)) / sum(logical(data.fr_matrix(and(data.fr_matrix(:,3) ~= partGroup, data.fr_matrix(:,3) ~= 3), 4)));
    end
    
    %SAVING PARTICIPANT DATA STRUCTURE
    data_path = sprintf('%s/behav/spaceDog_data_s%03d.mat',path,header.subnum);
    check_data_exist = dir(data_path);
    if length(check_data_exist) > 0
        disp(' ');
        disp('EXISTING PARTICIPANT DATA FOUND!');
        overwrite_confirm = input('Overwrite? (y/n): ','s');
        if strcmp(overwrite_confirm,'y')
            save(data_path,'data');
            disp(' ');
            disp('Overwrite confirmed. Participant data saved.');
        end
    else
        save(data_path,'data');
        disp(' ');
        disp('Participant data saved.');
    end
    
    if strcmp(header.subcond, 'n')
        group.non_prop = [group.non_prop; data.prop];
        group.non_wc = [group.non_wc; data.wc];
        group.non_wc_sum = [group.non_wc_sum; data.wc_sum];
        group.non_prop_a = [group.non_prop_a; data.prop_a];
        group.non_prop_b = [group.non_prop_b; data.prop_b];
        group.non_prop_c = [group.non_prop_c; data.prop_c];
        group.non_prop_cpr = [group.non_prop_cpr; data.prop_cpr];
        group.non_wc_a = [group.non_wc_a; data.wc_a];
        group.non_wc_b = [group.non_wc_b; data.wc_b];
        group.non_wc_c = [group.non_wc_c; data.wc_c];
        group.non_wc_cpr = [group.non_wc_cpr; data.wc_cpr];
    elseif strcmp(header.subcond, 'o')
        group.rep_prop = [group.rep_prop; data.prop];
        group.rep_wc = [group.rep_wc; data.wc];
        group.rep_wc_sum = [group.rep_wc_sum; data.wc_sum];
        group.rep_prop_a = [group.rep_prop_a; data.prop_a];
        group.rep_prop_b = [group.rep_prop_b; data.prop_b];
        group.rep_prop_c = [group.rep_prop_c; data.prop_c];
        group.rep_prop_cpr = [group.rep_prop_cpr; data.prop_cpr];
        group.rep_wc_a = [group.rep_wc_a; data.wc_a];
        group.rep_wc_b = [group.rep_wc_b; data.wc_b];
        group.rep_wc_c = [group.rep_wc_c; data.wc_c];
        group.rep_wc_cpr = [group.rep_wc_cpr; data.wc_cpr];
        group.rep_prop_r = [group.rep_prop_r; data.prop_r];
        group.rep_prop_n = [group.rep_prop_n; data.prop_n];
        group.rep_wc_r = [group.rep_wc_r; data.wc_r];
        group.rep_wc_n = [group.rep_wc_n; data.wc_n];
    elseif strcmp(header.subcond, 'p')
        group.pre_prop = [group.pre_prop; data.prop];
        group.pre_wc = [group.pre_wc; data.wc];
        group.pre_wc_sum = [group.pre_wc_sum; data.wc_sum];
        group.pre_prop_a = [group.pre_prop_a; data.prop_a];
        group.pre_prop_b = [group.pre_prop_b; data.prop_b];
        group.pre_prop_c = [group.pre_prop_c; data.prop_c];
        group.pre_prop_cpr = [group.pre_prop_cpr; data.prop_cpr];
        group.pre_wc_a = [group.pre_wc_a; data.wc_a];
        group.pre_wc_b = [group.pre_wc_b; data.wc_b];
        group.pre_wc_c = [group.pre_wc_c; data.wc_c];
        group.pre_wc_cpr = [group.pre_wc_cpr; data.wc_cpr];
        group.pre_prop_r = [group.pre_prop_r; data.prop_r];
        group.pre_prop_n = [group.pre_prop_n; data.prop_n];
        group.pre_wc_r = [group.pre_wc_r; data.wc_r];
        group.pre_wc_n = [group.pre_wc_n; data.wc_n];
    end
  
end

%saving group data structure array
data_path = sprintf('%s/behav/group_freeRecall.mat',path);
check_data_exist = dir(data_path);
if length(check_data_exist) > 0
    disp(' ');
    disp('EXISTING GROUP DATA FOUND!');
    overwrite_confirm = input('Overwrite? (y/n): ','s');
    if strcmp(overwrite_confirm,'y')
        save(data_path,'group');
        disp(' ');
        disp('Overwrite confirmed. Group data saved.');
    end
else
    save(data_path,'group');
    disp(' ');
    disp('Group data saved.');
end