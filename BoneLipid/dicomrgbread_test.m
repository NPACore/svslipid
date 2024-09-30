%
% BMP DICOM files
%
% @chm - 11/28/2022
%   ; Drafted - 11/28/2022
%
%

% 
%clear all;

%
addpath(genpath('~/usr/local/matlabtools/utils'));

% file
pfolder = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/DICOM_BMP_samples/';

flist = {...
    'RELCBF_0041/345-00-0178_B0686.MR.BRAIN_ROS-MOVE.0041.0001.2022.11.28.13.26.54.351743.64683569.IMA',...
    'RELCBF_RGB_40003/345-00-0178_B0686.MR.BRAIN_ROS-MOVE.40003.0001.2022.11.28.13.27.03.785283.114254072.IMA',...
    };
nlist = length(flist);

%% BMP DICOM reading
P = [pfolder '/' flist{1,2}];
info = dicominfo(P);
[X, map] = dicomread(P); 
%montage(X, map, 'Size', [2 5]);

%
imwrite(X,"ttdicom.jpg","Comment","DICOM BMP read-write");

%{
ImageComments: 'relCBF (PQ2T)'
SamplesPerPixel: 3
PhotometricInterpretation: 'RGB'
PlanarConfiguration: 0
Rows: 512
Columns: 512

SeriesNumber: 40003
AcquisitionNumber: 91

ProtocolName: 'Head_PASL'
SeriesDescription: 'relCBF_RGB'
FileSize: 901632
Format: 'DICOM'
FormatVersion: 3
%}

%%
% Read png
fname = 'ps.pdf-Page1.png';
[X1, map1] = imread(fname,'png');

% Conversion of png to DICOM
uid = dicomuid;

info.SeriesNumber       = info.SeriesNumber + 200;
info.SeriesInstanceUID  =  uid;
info.SeriesDescription = "BMPDICOM_test";

info.Rows = size(X1,1); % not sure direction                                      
info.Columns = size(X1,2);

info.ProtocolName = 'BMPDICOM';
                          
tname = '345-00-0178_B0686.MR.BRAIN_ROS-MOVE.0041.0001.2022.11.28.13.26.54.351743.64683569.IMA';
dicomwrite(X1, tname, info); 

% Confirm new DICOM same as original PNG file
[X1_, map1_] = dicomread(tname); 
imwrite(X1_,[fname '.png'],"Comment","png - dicom - png");


