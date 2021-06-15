@echo off
set var="%1 %2 %3 %4"
echo ImageJ-win64.exe --headless -macro threshold_manual.txt %var%
ImageJ-win64.exe --headless -macro threshold_manual.txt %var%
