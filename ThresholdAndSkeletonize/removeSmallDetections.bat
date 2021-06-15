@echo off
set var="%1 %2"
echo ImageJ-win64.exe --headless -macro removeSmallDetections.txt %var%
ImageJ-win64.exe --headless -macro removeSmallDetections.txt %var%
