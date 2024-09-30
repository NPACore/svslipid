%
% Reading csv file
%



pfolder = 'Y:\OngoingResearch\CSIProcessing\data\NIN-BOB\LBS098_2022.10.18-13.38.53\svs_se_30_12x12x12_leg_0x0.8';
filename = 'LBS098.csv';


P = [pfolder '/' filename];

skiprowlines = 0;
T = readtable(P,'PreserveVariableNames',true,'NumHeaderLines',skiprowlines);
disp(T);

skiprowlines = 1;
T1 = readtable(P,'PreserveVariableNames',true,'NumHeaderLines',skiprowlines);
disp(T1);

C = table2cell(T);
C1 = table2cell(T1); % same as C

% ... etc
for i=3:length(C)
    val = C{1,i};
    disp(val);
end