unit format_all;
//this unit determines file format
interface

uses SysUtils, eeg_type, format_edf, format_tms32, format_vhdr, dialogs,filter_all;

procedure  LoadEEGDummy(var lEEG: TEEG;lF1,lF2,lF3: single);
function  LoadEEG(lFilename: string; var lEEG: TEEG): boolean;
function WriteEEG(lFilename: string; var lEEG: TEEG): boolean;
function WriteEEGasTab(lFilename: string; var lEEG: TEEG): boolean;


implementation

procedure ZeroSamples (var lEEG: TEEG);
var
  c,nc,ns,s: integer;
begin
    nc := NumChannels(lEEG);
    if nc < 1 then
      exit;
    for c := 0 to nc-1 do begin
      ns := NumSamples(lEEG,C);
      if ns > 0 then
        for s := 0 to ns-1 do
          lEEG.Samples[c][s] := 0;
    end;
end;

procedure  LoadEEGDummy(var lEEG: TEEG; lF1,lF2,lF3: single);
var
   lChan,nchan,nsamp: integer;
begin
     nchan := 4;
     nsamp := 2048*8;
     setlength(lEEG.Channels,nchan);
     ClearEEGHdr (lEEG);
     for lChan := 0 to nChan -1 do begin
         lEEG.Channels[lChan].info :=  'c'+inttostr(lChan+1);
         lEEG.Channels[lChan].unittype :=  'uV';
         lEEG.Channels[lChan].SampleRate :=2048;
         lEEG.Channels[lChan].SignalLead := true;
     end;
     lEEG.Channels[nchan-1].SignalLead := false;
     setlength(lEEG.Samples,nChan,nsamp);
     ZeroSamples(lEEG);
     //AddSlope (lEEG,nChan-1,100);
     if lF1 <> 0 then
      AddTriggers (lEEG,nChan-1,lF1/2,100,5,0);
     if lF1 <> 0 then
      AddTriggers (lEEG,nChan-1,lF1/2,100,20,0.33);

     if lF1 <> 0 then
       for lChan := 0 to nChan -2 do
         AddSineWave(lEEG,lChan,lF1,33);
     if lF2 <> 0 then
       for lChan := 0 to nChan -3 do
         AddSineWave(lEEG,lChan,lF2,33);
     if lF3 <> 0 then
       for lChan := 0 to nChan -4 do
         AddSineWave(lEEG,lChan,lF3,33);
end;

function WriteEEG(lFilename: string; var lEEG: TEEG): boolean;
var
  Ext: string;
begin
      result := false;
      Ext:=UpperCase(ExtractFileExt(lFileName));
      if  Ext='.VHDR'  then
        result := WriteVHDR(lFilename,lEEG)
      else if  Ext='.S00'  then
        result := WriteTMS32(lFilename,lEEG)
      else if Ext='.EDF' then
        result := WriteEDF(lFilename,lEEG)
      else
        showmessage('Unknown format '+lFilename);
end;

function LoadEEG(lFilename: string; var lEEG: TEEG): boolean;
var
  Ext: string;
begin
      result := false;
      Ext:=UpperCase(ExtractFileExt(lFileName));
      lEEG.DataFile := extractfilename(lFilename);
      if  Ext='.VHDR'  then
        result := LoadVHDR(lFilename,lEEG)
      else if  Ext='.S00'  then
        result := LoadTMS32(lFilename,lEEG)
      else if Ext='.EDF' then
        result := LoadEDF(lFilename,lEEG)
      else
        showmessage('Unknown format '+lFilename);
end;

function WriteEEGastab(lFilename: string; var lEEG: TEEG): boolean;
const
  kDelim = Chr(9);//tab
var
  f : TextFile;
  str: string;
  c,s,nc,nS: integer;
  cra: array of integer;
begin
  result := false;
  nc := NumChannels(lEEG);
  ns := MaxNumSamples(lEEG);
  if (nc < 1) or (ns < 1) then
    exit;
  setlength(cra,nc);
  for c := 0 to nc-1 do
    cra[c] := NumSamples(lEEG,c)-1;//-1 as indexed from 0
  decimalseparator := '.';
  filemode := (2);
  AssignFile(f,lFilename);
  if fileexists (lFilename) then
    Append(f)
  else
    ReWrite(f);
  //header
  writeln(f,'Samples per second:');
  str:= '';
  for c := 0 to nc-1 do begin
    str := str+floattostr(lEEG.Channels[c].SampleRate);
    if c < (nc-1) then
        str := str+kDelim;
  end;
  WriteLn(f, str);
  writeln(f,'Label:');
  str:= '';       
  for c := 0 to nc-1 do begin
    str := str+lEEG.Channels[c].info;
    if c < (nc-1) then
        str := str+kDelim;
  end;
  WriteLn(f, str);
  //data...
  for s := 0 to ns -1 do begin
    str := '';
    for c := 0 to nc-1 do begin
      if cra[c]>=s then
        str := str+floattostr(lEEG.Samples[c][s]);
      if c < (nc-1) then
        str := str+kDelim;
    end;//each signal
    WriteLn(f, str);
  end;
  CloseFile(f);
  result := true;
end;



end.

