function svs_press_lipid_lcm(pfolder, dcmfname, strsptype, bverb)
% function svs_press_lipid_lcm(pfolder, strsptype, dcmfname)
% Input -
%   pfolder - study folder, ex, '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034'
%   dcmfname - SVS dicom file name, ex, 'AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA'
%   strsptype - ’lipid-8’, ’liver-11’, ’breast-8’, or ’only-cho-2’
%
%
% SVS PRESS LCModel
% @chm - 11/25/2022
%

%%
%clear all;

%% Screening
strpat = {'lipid-8', 'liver-11', 'breast-8', 'only-cho-2'};
TF = contains(strsptype,strpat);
if TF==false
    cprintf('*Red','Spectral type, %s is not valid!', strsptype);
    return;
end

%% Path
addpath(genpath('/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid'));

%% Folder
%pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034';
%dcmfname = 'AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA';

P = [pfolder '/' dcmfname];
TF = isfile([pfolder '/' dcmfname]);
if TF==false
    fprintf(2,'File not exist - %s\n', P);
    return;
end

%% DICOM loading
%
if bverb
    fprintf('Loading %s\n', dcmfname);
end

P = [pfolder '/' dcmfname];
%{
% dicom info
%info = dicominfo(P); % dicom info
info = SiemensCsaParse(P);
% spectroscopy data
fd = dicom_open(P);
tdata = dicom_get_spectrum_siemens(fd); % temporal data in complex format
fclose(fd);
%fdata = fftshift(fft(tdata)); % spectrum
%}
bDeleteFromInfo = false;
conjMode = false; %'conj';
debugMode = bverb; %'debug'
[signal, info] = SiemensCsaReadFid(dicominfo(P), bDeleteFromInfo, conjMode, debugMode);
%signal = conj(signal);

if bverb
    figure; plot(real(fftshift(fft(signal)))); axis tight; drawnow;
end

%% Retrieving the parameters from DICOM file
%
if bverb
    fprintf('\nRetrieving the parameters ...\n');
end

StudyDescription = info.StudyDescription; %'BODY^FAZ-TET'
ProtocolName = info.ProtocolName; % 'svs_se_30_L4'
PatientID = info.PatientID; %'AC10'

SequenceName = info.csa.SequenceName;
RepetitionTime = info.csa.RepetitionTime; %3000 msec
EchoTime = info.csa.EchoTime; %30 msec
ImagingFrequency = info.csa.ImagingFrequency; %123.2256 MHz
NumberOfAverages = info.csa.NumberOfAverages; %8
MagneticFieldStrength = info.csa.MagneticFieldStrength; %3
FlipAngle = info.csa.FlipAngle; %90
RealDwellTime = info.csa.RealDwellTime; %500000 nsec
BandWidth = 1/RealDwellTime; %Hz

SliceThickness = info.csa.SliceThickness; %15 mm
PixelSpacing = info.csa.PixelSpacing; %[15, 15]

SpectroscopyAcquisitionDataColumns = info.csa.SpectroscopyAcquisitionDataColumns; %1024
DataPointColumns = info.csa.DataPointColumns;

AcquisitionDuration = (RealDwellTime*1e-6)*SpectroscopyAcquisitionDataColumns; %msec

DataRepresentation = info.csa.DataRepresentation; %'COMPLEX'
SignalDomainColumns = info.csa.SignalDomainColumns; %'TIME'

ResonantNucleus = info.csa.ResonantNucleus; %'1H'

VoiThickness = info.csa.VoiThickness; %15
VoiPhaseFoV = info.csa.VoiPhaseFoV;
VoiReadoutFoV = info.csa.VoiReadoutFoV;
VOLUME = VoiThickness*VoiPhaseFoV*VoiReadoutFoV*1e-3; %cc

% etc
if 1
    strtmp = info.csa.MrPhoenixProtocol;
    idx1 = strfind(strtmp,'### ASCCONV BEGIN');
    idx2 = strfind(strtmp,'### ASCCONV END ###');
    strtmp = strtmp(idx1(1):idx2(:));
      
    %
    idxw = strfind(strtmp,'Wat');
    for i=1:length(idxw)
        strprev = strtmp(1:idxw(i));
        idxs = strfind(strprev, newline);
        strpost = strtmp(idxw(i):end);
        idxe = strfind(strpost, newline);
        strline = [strprev(idxs(end)+1:end-1) strpost(1:idxe(1)-1)];
        cprintf('[0.2,0.2,0.2]','...............%s\n',strline);
    end

end
RemoveOversampling= 'On';
WaterSuppr = 'None';
SpectralSuppr = 'None';

%% LCModel file names
rawfname = [pfolder '/' PatientID '.raw'];
controlfname = [pfolder '/' PatientID '.control'];
coordfname = [pfolder '/' PatientID '.coord'];

psfname = [pfolder '/' PatientID '.ps'];
corawfname = [pfolder '/' PatientID '.coraw'];
csvfname = [pfolder '/' PatientID '.csv'];

pdffname = [pfolder '/' PatientID '.pdf'];

%% Generating 'raw' file, *.raw
if bverb
    fprintf('Generating raw file ...\n');
end

fidraw = fopen(rawfname, 'wt'); % >>>
% SEQPAR
fprintf(fidraw,' $SEQPAR\n');
    %fprintf(fidraw, strcat(' ECHOT= ',num2str(EchoTime),'.\n'));
    fprintf(fidraw, ' ECHOT= %.2f\n',EchoTime);
    %fprintf(fidraw, strcat(' HZPPPM=',num2str(ImagingFrequency),'\n'));
    fprintf(fidraw,' HZPPPM= %.4e\n',ImagingFrequency);
    fprintf(fidraw,' SEQ= ''PRESS''\n');
fprintf(fidraw,' $END\n');
% NMID
fprintf(fidraw, strcat(' $NMID\n ID=''',PatientID,''', FMTDAT=''(2E15.6)''\n')); % when running Matlab on Linux
fprintf(fidraw, strcat(' TRAMP= 1.0, VOLUME= ',num2str(VOLUME),'\n $END\n'));
% Data
dataraw = zeros(2*SpectroscopyAcquisitionDataColumns,1);
dataraw(1:2:end) = real(signal);
dataraw(2:2:end) = imag(signal);
fprintf(fidraw,'%15.6e%15.6e\n', dataraw);
fclose(fidraw); % <<<

%% Control file *.control
if bverb
    fprintf('Generating control file ...\n');
end

title = [StudyDescription ' ' PatientID ' ' ProtocolName ' TR/TE=' num2str(RepetitionTime) '/' num2str(EchoTime) 'msec ' ...
    'NS=' num2str(NumberOfAverages)];
basis = '/raidgyrus2/users/moonc/.lcmodel/basis-sets/3T/gamma_press_te30_123mhz_106.basis';
srcraw = [pfolder '/' dcmfname];
savdir = [pfolder];
%
sptype= strsptype;
%sptype= 'lipid-8';
%
ppmst = 8.0;
ppmend = -1.0;
nunfil = SpectroscopyAcquisitionDataColumns;
%
deltat = RealDwellTime*1e-9; %sec
echot = EchoTime; %msec
%bverb
lps = 8;
lcsv = 11;
lcoord = 9;
%
if strcmp(sptype,'lipid-8')==true
    neach = 9;
    metab = cell(neach,1);
    metab{1,1} = 'L09+L13+L16';
    metab{2,1} = 'L09+L13+L23';
    metab{3,1} = 'Lip13+Lip16';
    metab{4,1} = 'L28+L23+L21';
    metab{5,1} = 'Lip13';
    metab{6,1} = 'Lip09';
    metab{7,1} = 'Lip16';
    metab{8,1} = 'Lip23';
    metab{9,1} = 'Lip28';
elseif strcmp(sptype,'liver-11')==true
    neach = 13;
    metab = cell(neach,1);
    metab{1,1} = 'L19+L09+L13';
    metab{2,1} = 'Lip16+Lip13';
    metab{3,1} = 'L28+L23+L21';
    metab{4,1} = 'L53+L52';
    metab{5,1} = 'Lip13';
    metab{6,1} = 'Lip09';
    metab{7,1} = 'Lip16';
    metab{8,1} = 'Lip21';
    metab{9,1} = 'Lip23';
    metab{10,1} = 'Lip28';
    metab{11,1} = 'Lip43';
    metab{12,1} = 'Lip41';
    metab{13,1} = 'Glycg';
else % lipid-8 as default
    neach = 9;
    metab = cell(neach,1);
    metab{1,1} = 'L09+L13+L16';
    metab{2,1} = 'L09+L13+L23';
    metab{3,1} = 'Lip13+Lip16';
    metab{4,1} = 'L28+L23+L21';
    metab{5,1} = 'Lip13';
    metab{6,1} = 'Lip09';
    metab{7,1} = 'Lip16';
    metab{8,1} = 'Lip23';
    metab{9,1} = 'Lip28';
end


fidlcm = fopen(controlfname, 'wt'); % >>>
% LCMODL
fprintf(fidlcm,'$LCMODL\n');

    fprintf(fidlcm,'OWNER=''MR Research Center, Radiology, Univ of Pittsburgh''\n');
    
    fprintf(fidlcm,['TITLE= ''', title,''' \n']); 
    fprintf(fidlcm,['SRCRAW= ''', srcraw,''' \n']); 
    fprintf(fidlcm,['SAVDIR= ''', savdir,''' \n']); 
    
    fprintf(fidlcm,'SPTYPE= ''%s''\n', sptype); 
         
    fprintf(fidlcm,['FILBAS= ''', basis,'''\n']); 
    fprintf(fidlcm, strcat('FILRAW=''', rawfname,''' \n'));
        
    fprintf(fidlcm,'LPS= %d\n',lps);
    fprintf(fidlcm,'LCSV= %d\n',lcsv);
    fprintf(fidlcm,'LCOORD= %d\n',lcoord);
    fprintf(fidlcm, strcat('FILCOO=''', coordfname,''' \n'));
    fprintf(fidlcm, strcat('FILPS=''', psfname,''' \n'));
    fprintf(fidlcm, strcat('FILCSV=''', csvfname,''' \n'));
    %fprintf(fidlcm, strcat('FILCOR=''', corawfname,''' \n')); 
        
    fprintf(fidlcm,'ECHOT= %.2f\n',echot);
    fprintf(fidlcm,'DELTAT= %.3e\n',deltat);
    fprintf(fidlcm,'HZPPPM= %.4e\n',ImagingFrequency);
    fprintf(fidlcm,'NUNFIL= %d\n',nunfil);
    
    fprintf(fidlcm,'PPMST= %.1f\n',ppmst);
    fprintf(fidlcm,'PPMEND= %.1f\n',ppmend);
    
    fprintf(fidlcm,'NEACH = %d\n', neach);  
    for i=neach:1
        fprintf(fidlcm,'NAMEAC(%d)= ''%s''\n', i, metab{i,1});  
    end

fprintf(fidlcm,'$END\n');
fclose(fidlcm); %<<<

%% LCModel
if bverb
    fprintf('Running lcmodel ...\n');
end

system(['~/.lcmodel/bin/lcmodel < ',controlfname]);

% conversion of 'ps' to 'pdf' file
strcmd = ['ps2pdf ' psfname ' ' pdffname];
[status,result] = system(strcmd);

if bverb
    fprintf('\nraw file - %s\n', rawfname);
    fprintf('control file - %s\n', controlfname);
    fprintf('coord file - %s\n', coordfname);
    fprintf('ps file - %s\n', psfname);
    fprintf('pdf file - %s\n', pdffname);
    %fprintf('coraw file - %s\n', corawfname);
    fprintf('csv file - %s\n', csvfname);
end

%% Remove path
rmpath(genpath('/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid'));

%%
return;

%%
%{
%raw

 $SEQPAR
 echot= 30.00
 seq= 'PRESS'
 hzpppm= 1.2323e+02
 $END
 $NMID
 id='AC10 ', fmtdat='(2E15.6)'
 volume=3.375e+00
 tramp=1.0
 $END
   1.226160e+05   0.000000e+00
   6.973790e+04   6.737041e+04
   3.268433e+03   3.634223e+04
   2.865584e+03  -3.152929e+04
   6.783641e+04  -4.781417e+04
  ...
  -1.771104e+03  -2.020980e+03
   2.430905e+03   3.017162e+03

%}

%{
% Control
$LCMODL
 title= 'AC10 (AC10) Series/Acq=34/1 (2020.09.21 16:18) svs_se_30_L4 TR/TE/NS=3000/30/8, 3.375E+00mL (F 031Y, 61.2349777395kg) BODY FAZ-TET  (MRRC)'
 srcraw= '/raidgyrus2/users/moonc/OngoingResearch/Cif bverbSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034/AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA'
 sptype= 'lipid-8'
 savdir= '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034/'
 ppmst= 8
 ppmend= -1.0
 nunfil= 1024
 neach= 7
 nameac(7)= 'Lip28'
 nameac(6)= 'Lip16'
 nameac(5)= 'Lip09'
 nameac(4)= 'Lip13'
 nameac(3)= 'L28+L23+L21'
 nameac(2)= 'Lip16+Lip13'
 nameac(1)= 'L16+L09+L13'
 lps= 8
 lcsv= 11
 lcoord= 9
 hzpppm= 1.2323e+02
 filraw= '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/met/RAW'
 filps= '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/ps'
 filcsv= '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/spreadsheet.csv'
 filcoo= '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/coord'
 filbas= '/raidgyrus2/users/moonc/.lcmodel/basis-sets/3T/gamma_press_te30_123mhz_106.basis'
 echot= 30.00
 deltat= 5.000e-04
lcsi_sav_1 = 12,  filcsi_sav_1 = '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/filcsi_sav_1', lcsi_sav_2 = 13,  filcsi_sav_2 = '/raidgyrus2/users/moonc/.lcmodel/temp/23d-20h-07m-27s-1592461pid/filcsi_sav_2'
 $END
%}

