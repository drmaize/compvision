@echo off
set var="%1 %2"
echo ImageJ-win64 --headless -macro threshold_default.txt %var%
ImageJ-win64 --headless -macro threshold_default.txt %var%
