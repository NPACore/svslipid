%%
% FAZ-TET SVS processing
%
% @chm - 11/25/2022
%

%% Current directory
pwd0 = pwd;

%%
%addpath(genpath('/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/cprintf'));


%% Scan archive folder
list_scandataFolder = {...
    '/disk/mace2/archive/scan_data_archive/2019',...
    '/disk/mace2/archive/scan_data_archive/2020',...
    '/disk/mace2/archive/scan_data_archive/2021',...
    '/disk/mace2/archive/scan_data_archive/2022',...
    '/disk/mace2/scan_data',...
    };
nscandb = length(list_scandataFolder);
%projectName = 'FAZ-TET';
%projectName = 'NIN-BOB';
projectName = 'FAZ-BMAT';

%% SVS sequences
if strcmp(projectName,'FAZ-TET')
     svs_scans = {...
       'svs_se_30_Femur_Epiphysis',...
       'svs_se_30_Femur_Metaphysis',...
       'svs_se_30_Femur_midDiaphysis',...
       'svs_se_30_L4',...
       'svs_se_30_Liver',...
     };
end
 
if strcmp(projectName,'NIN-BOB')
     svs_scans = {...
       'svs_se_30_12x12x12_leg',...
       'svs_se_30_15x15x15_lumbar',...
     };
end
 
if strcmp(projectName,'FAZ-BMAT')
     svs_scans = {...
       'svs_se_30_Femur_Epiphysis',...
       'svs_se_30_Femur_Metaphysis',...
       'svs_se_30_Femur_midDiaphysis',...
       'svs_se_30_L4',...
       'svs_se_30_Liver',...
     };
end

nlist = length(svs_scans);
   
    
%% scan data base
for iscandb=1:nscandb
  
    %scandataFolder = '/disk/mace2/scan_data'; %2022
    %scandataFolder = '/disk/mace2/archive/scan_data_archive/2021'; %2022 - 2021
    scandataFolder = list_scandataFolder{1,iscandb};

    %% Local folder for saving and processing
    localName = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data';
    localProjectName = [localName '/' projectName];
    TF = isfolder([localName '/' projectName]);
    if TF ~= true
        strcmd = ['mkdir ' localName '/' projectName];
        [status,result] = system(strcmd);
    end

    %% Data retrieval
    P0 = [scandataFolder '/' projectName];
    StudyDate = dir(P0);
    nStudyDate = length(StudyDate);

    cprintf('*Green','%s\n', P0);

    % StudyDate
    for i=3:nStudyDate % 2022.11.11-12.44.40
        name1 = StudyDate(i,1).name;
        folder1 = StudyDate(i,1).folder;
        date1 = StudyDate(i,1).date;
        isdir1 = StudyDate(i,1).isdir;
        fullname1 = [folder1 '/' name1];
        if isdir1==1
            P1 = [folder1 '/' name1];
            fprintf('...%s\n', name1);
            SubjectID = dir(P1);
            nSubjectID = length(SubjectID);
            % SubjectID
            for ii=3:nSubjectID %KB59
                name2 = SubjectID(ii,1).name;
                folder2 = SubjectID(ii,1).folder;
                date2 = SubjectID(ii,1).date;
                isdir2 = SubjectID(ii,1).isdir;
                fullname2 = [folder2 '/' name2];
                if isdir2==1
                    P2 = [folder2 '/' name2];
                    fprintf('......%s\n', name2);
                    SVSseries = dir(P2);
                    nSVSseries = length(SVSseries);
                    % Sequences
                    for iii=3:nSVSseries %svs_se_30_L4_0x0.27
                        name3 = SVSseries(iii,1).name;
                        folder3 = SVSseries(iii,1).folder;
                        date3 = SVSseries(iii,1).date;
                        isdir3 = SVSseries(iii,1).isdir;
                        fullname3 = [folder3 '/' name3];

                        % SVS or SVS_ref series
                        if isdir3==1
                            P3 = [folder3 '/' name3];
                            for j=1:nlist
                               strtmp = svs_scans{1,j};
                               IND = strfind(name3, strtmp);
                               if ~isempty(IND)
                                   %fprintf('.........%s\n', name3);
                                   localSubjectName = [localProjectName '/' name2 '_' name1];
                                   TF = isfolder(localSubjectName);
                                   if TF ~= true
                                        strcmd = ['mkdir ' localSubjectName];
                                        [status,result] = system(strcmd);
                                   end

                                   % screen - no lcmodel processing
                                   strpat = {'_ref_'};
                                   TF = contains(fullname3,strpat);
                                   if TF==true, continue; end

                                   IND = strfind(fullname3, '_0x0.');
                                   if isempty(IND) %svs_se_30_L4_0x0.8
                                       continue; 
                                   end

                                   % copy the series to local folder
                                   cprintf('*White','.........%s\n', name3);
                                   strcmd = ['cp -rf ' fullname3 ' ' localSubjectName '/.']; %disp(strcmd);
                                   [status,result] = system(strcmd);

                                   % -------------------------------------------
                                   % SVS LCModel 
                                   % -------------------------------------------
                                   Psvs = [localSubjectName '/' name3];
                                   SVSdicom = dir(Psvs);
                                   nSVSdicom = length(SVSdicom); %disp(num2str(nSVSdicom));

                                   if nSVSdicom > 3
                                       fprintf(2,'............One more files are detected\n');
                                   end
                                   for k=3:nSVSdicom
                                       name_ = SVSdicom(k,1).name;
                                       folder_ = SVSdicom(k,1).folder;
                                       date_ = SVSdicom(k,1).date;
                                       isdir_ = SVSdicom(k,1).isdir;
                                       if isdir_==true
                                           continue;
                                       end

                                       % run lcmodel
                                       strpat = {'.raw','.control','.csv','.ps','.coord'};
                                       TF = contains(name_,strpat);
                                       if TF==true
                                           continue;
                                       end


                                       strpat = {'_Liver_'};
                                       TF = contains(name3,strpat);
                                       if TF==true
                                           % Liver
                                           cprintf('Blue','............%s\n', name_);
                                           %svs_press_liver_lcm(folder_, name_, false);
                                           continue;
                                       else
                                           % Bone
                                           cprintf('White','............%s\n', name_);
                                           svs_press_bone_lcm(folder_, name_, false);
                                       end

                                    end
                                   % -------------------------------------------


                               end
                            end

                        end
                    end



                end
            end

        end
    end



end
%%
%rmpath(genpath('/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/cprintf'));

%{
svs_se_30_Femur_Epiphysis_0x0.8
svs_se_30_Femur_Metaphysis_0x0.11
svs_se_30_Femur_midDiaphysis_0x0.19
svs_se_30_L4_0x0.27
svs_se_30_Liver_0x0.35
%}
    
% Retrun to current directory
cd(pwd0);