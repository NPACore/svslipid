%
% SVS LCModel demo
%
% @chm - 11/25/2022
%

%
clear all;

% path & file
pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034';
dcmfname = 'AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA';

pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/KB59/svs_se_30_Femur_midDiaphysis_ref_0x0.18';
dcmfname = 'UNKNOWN.1.3.12.2.1107.5.2.38.51021.2022111114042098534192420';

pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/KB59/svs_se_30_L4_0x0.8';
dcmfname = 'UNKNOWN.1.3.12.2.1107.5.2.38.51021.2022021108512067772670073';

%pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10/SVS_SE_30_L4_0034';
%dcmfname = 'AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA';

% run
svs_press_bone_lcm(pfolder, dcmfname, true);