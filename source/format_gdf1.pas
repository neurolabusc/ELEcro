unit format_gdf;
//support for GDF format ..
//http://www.dpmi.tu-graz.ac.at/schloegl/matlab/eeg/
//GDF 1
//  http://www.dpmi.tu-graz.ac.at/schloegl/matlab/eeg/
//GDF2
//  http://arxiv.org/abs/cs.DB/0608052
interface
uses eeg_type, sysutils,dialogs, DateUtils,deb;

function LoadGDF(lFilename: string; var lEEG: TEEG): boolean;
function WriteGDF(lFilename: string; var lEEG: TEEG): boolean;

implementation
const
  kSig = 'GDF 0.12';
type
  TEEGHdr = packed record //Next: EDF header
   VERSION: array [1..8] of char;  //singature =  'GDF 2.10'
   PID: array [1..80] of char; //80 Patient ID
   RID : array [1..80] of byte;
   STARTDATE: array [1..16] of char;//YYYYMMDDhhmmsscc
   HDRBYTES : Int64;
   MANID,LABID,TECID: UINT64;
   SERIAL: array [1..20] of char;
   RECORDS: int64;
   DURATION: array[1..2] of longword;
   NS: longword;
 end; //TEEGHdr Header Structure

 TChanHdr = packed record //Next: Poly5 header
    Labl: array [1..16] of char;
    Transducer : array [1..80] of char;
    dimension: array [1..8] of char;
    physicalmin,physicalmax: double;
    digitalmin,digitalmax: int64;
    Filter : array [1..80] of char;
    NR,chantype: longword;
    Reserved : array [1..32] of char;
    {Impedance: byte;
    Reserved : array [1..32] of char; {}
 end;

procedure Str2Array(lIn: string; var lOut: array of char);
var
  Len,i: integer;
begin
  Len := length(lIn);
  if length(lOut) < Len then
    Len := length(lOut);
  if Len < 1 then
    exit;
  for i := 1 to Len do
    lOut[i-1] := lIn[i];
  if Len < length(lOut) then
    for i := Len+1 to length(lOut) do
      lOut[i-1] := chr($20);
end;

(*procedure TDate2Hdr (lTime : TDateTime; var EEGHdr: TEEGHdr);
//STARTDATE = dd.mm.yy ::   STARTTIME = hh.mm.ss
var
  lYY,lDD,lMo,lHH,lMi,lSS, lMs : Word;
begin
  //Str2Array('12.34.56',EEGHdr.STARTTIME);//hh.mm.ss
  //Str2Array('12.12.99',EEGHdr.STARTDATE);//dd.mm.yy
  DecodeDateTime(lTime, lYY, lMo, lDD, lHH, lMi, lSS, lMs);
  if (lYY < 1985) or (lYY > 2084) then begin
    showmessage('This software is really obsolete.');
    exit;
  end;
  if lYY > 1999 then
    lYY := lYY - 2000
  else
    lYY := lYY - 1900;
  Str2Array(Format('%.*d', [2, lDD])+'.'+Format('%.*d', [2, lMo])+'.'+Format('%.*d', [2, lYY]), EEGHdr.STARTDATE);
  Str2Array(Format('%.*d', [2, lHH])+'.'+Format('%.*d', [2, lMi])+'.'+Format('%.*d', [2, lSS]), EEGHdr.STARTTIME);
end;*)

function SamplesPerRecord (NS,sampperchannel: integer): integer;
const
  kRecBytes= 61440;
//we want as few records as possible, so our time resolution will avoid rounding errors.
//However....
// sampperchannel must be divisible by recordsize
// record size should not exceed   kRecBytes
var
  i,s,bytes: integer;
begin
  result := 1;
  s := 2;
  for i := 1 to 16 do begin
    bytes := s*2{16-bit ints}*NS;
    if bytes > kRecBytes then
      exit;
    if (sampperchannel mod s) = 0 then
      result := s
    else
      exit;
    s := s * 2;
  end;
end;

function WriteGDF(lFilename: string; var lEEG: TEEG): boolean;
var
  EEGHdr: TEEGHdr;
  Hz: double;
  lsampperrec,Sig,NS,s,r,lsampperchannel,i,j,lnrec: integer;
  fp: file;
  ChanRA: array of TChanHdr;
  DataRA: array of smallint;
begin
  decimalseparator := '.';
  result := false;
  NS := NumChannels(lEEG);
  if NS < 1 then
    exit;
  //first maximum number of recordings for any channel
  lsampperchannel := NumSamples(lEEG,0);
  for Sig := 0 to (NS-1) do
    if NumSamples(lEEG,Sig) <> lsampperchannel then begin
        showmessage('Can only create EDF files where all channels have the same number of signals');
        exit;
    end;
  lsampperrec :=  SamplesPerRecord (NS,lsampperchannel);
  lnrec := lsampperchannel div lsampperrec;
  Hz := lEEG.Channels[0].SampleRate;
  for Sig := 0 to (NS-1) do
    if lEEG.Channels[Sig].SampleRate <> Hz then begin
        showmessage('Can create EDF files where all channels have same sampling rate');
        exit;
    end;
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Rewrite(fp, 1);
  FillChar(EEGHdr, SizeOf(TEEGHdr), $20);
  Str2Array('0',EEGHdr.VERSION);
//  TDate2Hdr (lEEG.Time,EEGHdr) ;
//  Str2Array(inttostr(NS),EEGHdr.NS);
//  Str2Array('',EEGHdr.Reserved);
  //EDF+ support requires 'Str2Array('EDF+C',EEGHdr.Reserved); //'EDF+C'
  // and a new signal type : EDF Annotations
(*  Str2Array(floattostr(1/Hz* lsampperrec),EEGHdr.DURATIONSEC);
  Str2Array(inttostr(lnrec),EEGHdr.RECORDS);
  Str2Array(inttostr((NS+1)*256),EEGHdr.HDRBYTES); //main header is 256 bytes, +256 per channel
  BlockWrite(fp, EEGHdr, SizeOf(TEEGHdr));
  SetLength( ChanRA, NS );
  for Sig := 1 to NS do begin
    FillChar(ChanRA[Sig-1], SizeOf(TChanHdr), $20);
      Str2Array(lEEG.Channels[Sig-1].Info,ChanRA[Sig-1].Labl);
      Str2Array(lEEG.Channels[Sig-1].Info,ChanRA[Sig-1].Transducer);
    if lEEG.Channels[Sig-1].UnitType[1] = chr($B5) then
      Str2Array('uV',ChanRA[Sig-1].dimension)
    else
      Str2Array(lEEG.Channels[Sig-1].UnitType,ChanRA[Sig-1].dimension);
    Str2Array(inttostr(-32767),ChanRA[Sig-1].minimum);
    Str2Array(inttostr(32767),ChanRA[Sig-1].maximum);
    Str2Array(inttostr(-32767),ChanRA[Sig-1].digminimum);
    Str2Array(inttostr(32767),ChanRA[Sig-1].digmaximum);
    Str2Array(inttostr(lsampperrec),ChanRA[Sig-1].samples);
    Str2Array('',ChanRA[Sig-1].Res);
   end;
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].Labl,SizeOf(ChanRA[Sig-1].Labl));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].Transducer,SizeOf(ChanRA[Sig-1].Transducer));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].dimension,SizeOf(ChanRA[Sig-1].dimension));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].minimum,SizeOf(ChanRA[Sig-1].minimum));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].maximum,SizeOf(ChanRA[Sig-1].maximum));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].digminimum,SizeOf(ChanRA[Sig-1].digminimum));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].digmaximum,SizeOf(ChanRA[Sig-1].digmaximum));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].Prefilter,SizeOf(ChanRA[Sig-1].Prefilter));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].samples,SizeOf(ChanRA[Sig-1].samples));
   for Sig := 1 to NS do
      BlockWrite(fp,ChanRA[Sig-1].Res,SizeOf(ChanRA[Sig-1].Res));
   SetLength( DataRA, lsampperchannel*NS );
   i := 0;
   j := 0;
   for r := 1 to lnrec do begin
    for Sig := 0 to (NS-1) do begin
      for s := 0 to ( lsampperrec-1) do begin
        DataRA[i] := round(lEEG.Samples[Sig][j+s]);
        inc(i);
      end; //for each sample in record
    end;//for each channle;
    j := j + lsampperrec;
   end; //for each record
   BlockWrite(fp,DataRA[0],lsampperchannel*NS * sizeof(smallint));
   CloseFile(fp);
   result := true;  *)
end;

function ValidNumber(Ch1,Ch2: char; var lV: integer):boolean; overload;
begin
    result := false;
    if (not(Ch1 in ['0'..'9'])) or (not(Ch1 in ['0'..'9'])) then
      exit;
    lV := strtoint(Ch1+Ch2);
end;

function ValidNumber(Ch1,Ch2,Ch3,Ch4: char; var lV: integer):boolean; overload;
begin
    result := false;
    if (not(Ch1 in ['0'..'9'])) or (not(Ch1 in ['0'..'9'])) Or  (not(Ch3 in ['0'..'9'])) or (not(Ch4 in ['0'..'9'])) then
      exit;
    lV := strtoint(Ch1+Ch2+Ch3+Ch4);
end;

function Time2TDate (EEGHdr: TEEGHdr): TDateTime;
var
  lYY,lDD,lMo,lHH,lMi,lSS,lCC : integer;
//YYYYMMDDhhmmsscc
begin
    result := now;//666
   if not ValidNumber(EEGHdr.STARTDATE[1],EEGHdr.STARTDATE[2],EEGHdr.STARTDATE[3],EEGHdr.STARTDATE[4],lYY) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[5],EEGHdr.STARTDATE[6],lMo) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[7],EEGHdr.STARTDATE[8],lDD) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[9],EEGHdr.STARTDATE[10],lHH) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[11],EEGHdr.STARTDATE[12],lMi) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[13],EEGHdr.STARTDATE[14],lSS) then exit;
   if not ValidNumber(EEGHdr.STARTDATE[14],EEGHdr.STARTDATE[15],lCC) then exit;
      if not IsValidDateTime(lYY, lMo, lDD, lHH, lMi, lSS, 0) then
      exit;
  result := EncodeDateTime(lYY, lMo, lDD, lHH, lMi, lSS, 0);
end;

function LoadGDF(lFilename: string; var lEEG: TEEG): boolean;
var
  fp: file;
  //l16: smallint;
  r,p,i,s,Sig,NS,Rec,sz,maxsamp: integer;
  samplesec: double;
  EEGHdr: TEEGHdr;
  Labl: array [1..16] of char;
  Transducer,Prefilter : array [1..80] of char;
  dimension,minimum,maximum,digminimum,digmaximum,samples : array [1..8] of char;
  Res : array [1..32] of char;
  SampRA: array of integer;
  DataRA: array of smallint;
begin
  decimalseparator := '.';
  result := false;
  FileMode := 0; //set to readonly
  AssignFile(fp, lFileName);
  Reset(fp, 1);
  if FileSize(fp) <  sizeof(TEEGHdr) then
    raise Exception.Create('To small to be an GDF file :'+lFilename);
  seek(fp, 0);
  BlockRead(fp, EEGHdr, SizeOf(TEEGHdr));
  if (lEEG.
  lEEG.Time := Time2TDate(EEGHdr);//Time2TDate(EEGHdr);
  //showmessage(FormatDateTime('yyyymmdd_hhnnss', (lEEG.Time))) ;
  samplesec := EEGHdr.DURATION[1]/EEGHdr.DURATION[2];
   NS := EEGHdr.NS;//strtoint(Trim(EEGHdr.NS));
   if NS < 1 then
    raise Exception.Create('EDF file has unexpected number of signals:'+inttostr(NS));
   Rec :=  EEGHdr.RECORDS;
   if Rec < 1 then
    raise Exception.Create('EDF file has unexpected number of records:'+inttostr(Rec));
    setlength(lEEG.Channels,NS);
   ClearEEGHdr ( lEEG);
   for Sig := 1 to NS do begin
      BlockRead(fp,Labl,SizeOf(Labl));
      lEEG.Channels[Sig-1].Info := Trim(Labl);
   end;
   for Sig := 1 to NS do
      BlockRead(fp,Transducer,SizeOf(Transducer));
   for Sig := 1 to NS do begin
      BlockRead(fp,dimension,SizeOf(dimension));
      lEEG.Channels[Sig-1].UnitType := Trim(dimension);
      //showmessage(inttostr(Sig)+':'+inttostr(NS)+lEEG.Channels[Sig-1].UnitType );
      if length(lEEG.Channels[Sig-1].UnitType) > 0 then
      if (lEEG.Channels[Sig-1].UnitType[1] = '�') or (lEEG.Channels[Sig-1].UnitType[1] = 'u') then
        lEEG.Channels[Sig-1].SignalLead := true
      else
        lEEG.Channels[Sig-1].SignalLead := false;
   end;
   for Sig := 1 to NS do
      BlockRead(fp,minimum,SizeOf(minimum));
   for Sig := 1 to NS do
      BlockRead(fp,maximum,SizeOf(maximum));
   for Sig := 1 to NS do
      BlockRead(fp,digminimum,SizeOf(digminimum));
   for Sig := 1 to NS do
      BlockRead(fp,digmaximum,SizeOf(digmaximum));
   for Sig := 1 to NS do
      BlockRead(fp,Prefilter,SizeOf(Prefilter));
   SetLength( SampRA, NS );
   for Sig := 1 to NS do begin
      BlockRead(fp,samples,SizeOf(samples));
      SampRA[Sig-1] := strtoint(Trim(samples));
      lEEG.Channels[Sig-1].SampleRate := SampRA[Sig-1]/SampleSec ;
   end;
   for Sig := 1 to NS do begin
      BlockRead(fp,Res,SizeOf(Res));
   end;
   maxsamp := 0;
   for Sig := 0 to (NS-1) do
    if SampRA[Sig] > maxsamp then
      maxsamp :=  SampRA[Sig];
   for Sig := 0 to (NS-1) do
    if SampRA[Sig] <>  SampRA[0] then
      showmessage('This viewer may not show this EDF file correctly (annotations or variable sampling rate).');
   i := 0;
   for Sig := 1 to NS do begin
    i := i + rec*SampRA[Sig-1];
   end;
   if maxsamp < 1 then
    exit;
   sz := sizeof(TEEGHdr)+NS*sizeof(TChanHdr)+i*2;
   if sz > filesize(fp) then begin
       showmessage('EDF file smaller than described in header. Actual: '+inttostr(filesize(fp))+'  expected: '+inttostr(sz) );
       exit;
   end;
   setlength(lEEG.Samples,NS,maxsamp*rec);
  for r := 0 to maxsamp-1 do
    for Sig := 0 to (NS-1) do
        lEEG.Samples[Sig][r]  := 0;
   setlength(DataRA,i);
  BlockRead(fp,DataRA[0],i * sizeof(smallint));
  p := 0;
  for r := 1 to rec do begin
    for Sig := 0 to (NS-1) do begin
      if SampRA[Sig] > 0 then begin
        i := (r-1)*  SampRA[Sig];
        for s := 1 to SampRA[Sig] do begin
          lEEG.Samples[Sig][i]  := DataRA[p];
          inc(i);
          inc(p);
        end; //for each Samp
      end;//at least 1 sample t read
    end; //for each Sig
   end; // for each record
   CloseFile(fp);
   FileMode := 2; //set to readwrite    *)
   result := true;
end; //LoadFromEDFStream

end.
