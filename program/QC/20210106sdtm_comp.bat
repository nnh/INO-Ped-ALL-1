@echo on
set target1=\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\sdtm\*.csv
set target2=\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\input\sdtm\20201214\*.csv
set outputpath=\\aronas\Stat\Trials\Chiken\INO-Ped-ALL-1\compare\
set compdate=%date:~0,4%%date:~5,2%%date:~8,2%
set outputfilename=comp_sdtm_%compdate%.txt
echo ********** compare start ********** > %outputpath%%outputfilename%
dir %target1% >> %outputpath%%outputfilename%
dir %target2% >> %outputpath%%outputfilename%
echo N|comp %target1% %target2% >> %outputpath%%outputfilename%
echo ********** compare end ********** >> %outputpath%%outputfilename%
