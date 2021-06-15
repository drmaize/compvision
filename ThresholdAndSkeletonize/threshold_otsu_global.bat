@echo off
set var="%1 %2"
echo ImageJ-win64.exe --headless -macro threshold_otsu_global.txt %var%
ImageJ-win64.exe --headless -macro threshold_otsu_global.txt %var%
