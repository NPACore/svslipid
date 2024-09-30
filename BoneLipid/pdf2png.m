%
% Convert pdf to png file
%

%
addpath('~/usr/local/matlabtools/utils');

%
fname = '/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/ps.pdf';

%
images = PDFtoImg(fname);

%
rmpath('~/usr/local/matlabtools/utils');



%{
@ MATLAB Version: 9.10.0.1851785 (R2021a) Update 6; Working

@ MATLAB Version: 9.5.0.1298439 (R2018b) Update 7; Error as following
Error using PDFtoImg (line 6)
Java exception occurred:
java.io.FileNotFoundException:
/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/raidgyrus2/users/moonc/OngoingResearch/CSIProcessing/Codes/BoneLipid/ps/pdf
(No such file or directory)
	at java.io.RandomAccessFile.open0(Native Method)
	at java.io.RandomAccessFile.open(RandomAccessFile.java:316)
	at java.io.RandomAccessFile.<init>(RandomAccessFile.java:243)
	at
        org.apache.pdfbox.io.RandomAccessBufferedFileInputStream.<init>(RandomAccessBufferedFileInputStream.java:99)
        	at
        org.apache.pdfbox.pdmodel.PDDocument.load(PDDocument.java:1006)
	at org.apache.pdfbox.pdmodel.PDDocument.load(PDDocument.java:969)
	at org.apache.pdfbox.pdmodel.PDDocument.load(PDDocument.java:917)
%}
