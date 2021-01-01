del /S *.~*
del /S *.ppu
del /S *.o
del /S *.dcu
del /S *.obj
del /S *.hpp
del /S *.ddp
del /S *.mps
del /S *.mpt
del /S *.dsm
C:\strip  /B  "C:\pas\Delphi\erp\EEG.exe"

del eeg.zip
c:\Progra~1\7-Zip\7z a -tzip eeg.zip
del win.zip
c:\Progra~1\7-Zip\7z a -tzip win.zip *.exe

copy eeg.zip Z:\html\nl\tools\elecro\eeg.zip
copy win.zip Z:\html\nl\tools\elecro\win.zip