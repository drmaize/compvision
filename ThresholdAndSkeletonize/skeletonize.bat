@echo off
set var="%1 %2"
echo ImageJ-win64 --headless -macro skeletonize.txt %var%
ImageJ-win64 --headless -macro skeletonize.txt %var%
