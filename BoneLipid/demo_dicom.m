clear all;



%{
% Phillips' Demo
fd = dicom_open('/home/gmr/work/academic/phd/data/nottingham/DICOM/XX_0106');
y_ph = dicom_get_spectrum_phillips(fd);
fclose(fd);

% Siemens' Demo
fd = dicom_open('/home/gmr/work/academic/phd/data/phantom_single/03311921/16167579');
y_s = dicom_get_spectrum_siemens(fd);
fclose(fd);
%}


%% @chm - testing
pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/data/FAZ-TET/AC10_AC10/SVS_SE_30_L4_0034';
fname = 'AC10.MR.BODY_FAZ-TET.0034.0001.2020.09.21.16.46.40.41595.117088455.IMA';

P = [pfolder '/' fname];

% dicom info
info = dicominfo(P);
% spectrum
fd = dicom_open(P);
y_s = dicom_get_spectrum_siemens(fd);
fclose(fd);

% plot
fy_s = fftshift(fft(y_s));
figure(1); plot(real(fy_s));


%%
disp('done');