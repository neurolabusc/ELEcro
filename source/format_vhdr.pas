unit format_vhdr;
//support for BrainProducts VHDR format ..

interface
uses eeg_type, sysutils,dialogs, DateUtils,IniFiles, StrUtils,deb;

function LoadVHDR(lFilename: string; var lEEG: TEEG): boolean;
function WriteVHDR(lFilename: string; var lEEG: TEEG): boolean;

implementation

(*procedure IniInt(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: integer);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('INT',lIdent,IntToStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('INT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToInt(lStr);
end; //IniInt*)

(*procedure IniStr(lRead: boolean; lIniFile: TIniFile; lSection,lIdent: string; var lValue: string);
//read or write a string value to the initialization file
begin
  if not lRead then begin
    lIniFile.WriteString(lSection,lIdent,lValue);
    exit;
  end;
	lValue := lIniFile.ReadString(lSection,lIdent, '');
end; //IniStr  *)
procedure WIniInt(lIniFile: TIniFile; lSection,lIdent: string;  lValue: integer);
//read or write a string value to the initialization file
begin
    lIniFile.WriteString(lSection,lIdent,inttostr(lValue));
end; //IniStr

procedure WIniDouble(lIniFile: TIniFile; lSection,lIdent: string;  lValue: double);
//read or write a string value to the initialization file
begin
    lIniFile.WriteString(lSection,lIdent,floattostr(lValue));
end; //IniStr

procedure WIniStr(lIniFile: TIniFile; lSection,lIdent: string;  lValue: string);
//read or write a string value to the initialization file
begin
    lIniFile.WriteString(lSection,lIdent,lValue);
end; //IniStr

function SaveASCII (lFilename: string; var lEEG: TEEG; VECTORIZED: boolean): boolean;
const
  kDelim = Chr(9);//tab
var
  f : TextFile;
  str: string;
  c,s,nc,nS: integer;
begin
  result := false;
  NC := NumChannels(lEEG);
  NS := NumSamplesZeroIfVariable(lEEG);
  if (NC < 1) or (NS < 1) then
    exit;
  decimalseparator := '.';
  filemode := (2);
  AssignFile(f,lFilename);
  ReWrite(f);
  //data...
  if VECTORIZED then begin
    for c := 0 to nc-1 do begin
      for s := 0 to ns -1 do begin
        write(f,floattostr(lEEG.Samples[c][s]));
        if c < (nc-1) then
          write(f,kDelim);
    end;//each signal
    WriteLn(f,'');
   end;
  end else begin
   for s := 0 to ns -1 do begin
    str := '';
    for c := 0 to nc-1 do begin
        str := str+floattostr(lEEG.Samples[c][s]);
      if c < (nc-1) then
        str := str+kDelim;
    end;//each signal
    WriteLn(f, str);
   end;
  end;//not a vector
  CloseFile(f);
  result := true;
end;

function SaveFloat (lFilename: string; var lEEG: TEEG; VECTORIZED: boolean): boolean;
var
  fp: file;
  S,C,NC,NS: integer;
begin
  result := false;
  NC := NumChannels(lEEG);
  NS := NumSamplesZeroIfVariable(lEEG);
  if (NC < 1) or (NS < 1) then
    exit;
  //first maximum number of recordings for any channel
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Rewrite(fp, 1);
  if  VECTORIZED then begin
    for C := 0 to NC - 1 do
      blockwrite(fp,lEEG.Samples[c][0],NS*sizeof(single))
  end else begin //not a vector
    for S := 0 to NS - 1 do
      for C := 0 to NC - 1 do
        blockwrite(fp,lEEG.Samples[c][s],sizeof(single));
  end;
  CloseFile(fp);
  result := true;
end;

function WriteV(lFilename: string; var  lEEG: TEEG; BINARY,VECTORIZED: boolean): boolean;
//Read or write initialization variables to disk
var
  f : TextFile;
  //lIniFile: TIniFile;
  lC, lNS: integer;
  lDatName: string;
begin
  result := false;
  lNS := NumSamplesZeroIfVariable(lEEG);
  if (NumChannels(lEEG) < 1) or (lNS < 1) or (SampleRateZeroIfVariable(lEEG) < 1) then begin
    showmessage('VHDR error: no data to write or variable number of samples.');
    exit;
  end;
  filemode:= fmOpenReadWrite;
  AssignFile(f,lFilename);
  Rewrite(f);
  WriteLn(f, 'Brain Vision Data Exchange Header File Version 1.0');
  WriteLn(f, '[Common Infos]');
  lDatName := changefileext(extractfilename(lFilename),'.eeg');
  WriteLn(f, 'DataFile='+lDatName);
    lDatName := changefileext(lFilename,'.eeg'); //save in same folder
  if BINARY then
    WriteLn(f, 'DataFormat=BINARY')
  else
    WriteLn(f, 'DataFormat=ASCII');
  if VECTORIZED then
    WriteLn(f, 'DataOrientation=VECTORIZED')
  else
    WriteLn(f, 'DataOrientation=MULTIPLEXED');
  WriteLn(f, 'DataType=TIMEDOMAIN');
  WriteLn(f, 'NumberOfChannels='+inttostr(NumChannels(lEEG)));
  //WriteLn(f, 'SamplingInterval='+inttostr(round((1000/lEEG.Channels[0].SampleRate) * 1000)));
  WriteLn(f, 'SamplingInterval='+floattostr(((1000/lEEG.Channels[0].SampleRate) * 1000)));
  WriteLn(f, 'DataPoints='+inttostr(lNS));
  if BINARY then begin
    WriteLn(f, '[Binary Infos]');
    WriteLn(f, 'BinaryFormat=IEEE_FLOAT_32');
  end else begin
    WriteLn(f, '[ASCII Infos]');
    WriteLn(f, 'DecimalSymbol=.');
    //WriteLn(f, 'SkipLines=0');
    //WriteLn(f, 'SkipColumns=0');
  end;
  WriteLn(f, '[Channel Infos]');
  for lC := 1 to NumChannels(lEEG) do begin
    if not lEEG.Channels[lC-1].SignalLead then
      WriteLn(f,'Ch'+Inttostr(lC)+'='+ lEEG.channels[lC-1].Info+',,1,Digital')
    else
      WriteLn(f,'Ch'+Inttostr(lC)+'='+ lEEG.channels[lC-1].Info+',,1,µV')
  end;
  CloseFile(f);
  //put signature in first line of vhdr...
  if BINARY then
    result := SaveFloat(lDatName, lEEG, VECTORIZED)
  else
    result := SaveASCII(lDatName, lEEG, VECTORIZED)
end;

function WriteVHDR(lFilename: string; var lEEG: TEEG): boolean;
begin
  WriteV(lFilename,lEEG, TRUE,TRUE); //BINARY, VECOTR
  //VECTORIZED TEXT WORKS POORLY...WriteV(lFilename,lEEG, FALSE,TRUE); //BINARY, VECOTR
  //IF you want text output, use multiplexed text ...WriteV(lFilename,lEEG, FALSE,FALSE); //BINARY, VECOTR

end;

function RIniInt(lIniFile: TIniFile; lSection,lIdent: string;  lDefault: integer): integer;
//read or write an integer value to the initialization file
var
	lStr: string;
begin
  result := lDefault;
	lStr := lIniFile.ReadString(lSection,lIdent, '');
	if length(lStr) > 0 then
		result := StrToInt(lStr);
end; //IniInt

function RIniDouble(lIniFile: TIniFile; lSection,lIdent: string;  lDefault: double): double;
//read or write an integer value to the initialization file
var
	lStr: string;
begin
  result := lDefault;
	lStr := lIniFile.ReadString(lSection,lIdent, '');
	if length(lStr) > 0 then
		result := StrToFloat(lStr);
end; //IniInt

function RIniStr(lIniFile: TIniFile; lSection,lIdent: string; lDefault: string): string;
//read or write a string value to the initialization file
begin
	result := lIniFile.ReadString(lSection,lIdent, '');
  if result = '' then
    result := lDefault;
end; //IniStr

function LoadBinary (lFilename: string; var lEEG: TEEG; NC,NS, lFormat: integer; VECTORIZED: boolean): boolean;
var
  fp: file;
  uint16: word;
  int16: smallint;
  S,C: integer;
  i64: int64;
begin
  result := false;
  if not fileexists(lFilename) then begin
    showmessage('Can not find file '+lFilename);
    exit;
  end;
  if (NC < 1) or (NS < 1) then
    exit;
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Reset(fp, 1);
  i64 := NC*NS*abs(lFormat div 8); //size in bytes
  if filesize(fp) < i64 then begin
    showmessage('Error: File '+lFileName + ' is '+inttostr(filesize(fp))+' bytes, but should be '+inttostr(i64));
    CloseFile(fp);
    exit;
  end;
  if lFormat = 32 then begin //IEEE-32 float single precision
    if  VECTORIZED then begin
     //showmessage('666 vector 32');
      for C := 0 to NC - 1 do
        blockread(fp,lEEG.Samples[c][0],NS*sizeof(single))
    end else begin //not a vector
      for S := 0 to NS - 1 do
        for C := 0 to NC - 1 do
          blockread(fp,lEEG.Samples[c][s],sizeof(single));
    end;
  end else if lFormat = 16 then begin //uint16
    if  VECTORIZED then begin
      for C := 0 to NC - 1 do
        for S := 0 to NS - 1 do BEGIN
          blockread(fp,uint16,sizeof(word));
          lEEG.Samples[c][s]:= uint16;
        end;

    end else begin //not a vector
      for S := 0 to NS - 1 do
        for C := 0 to NC - 1 do begin
          blockread(fp,uint16,sizeof(word));
          lEEG.Samples[c][s]:= uint16;
        end;
    end;
  end else begin //int16
    if  VECTORIZED then begin
      for C := 0 to NC - 1 do
        for S := 0 to NS - 1 do BEGIN
          blockread(fp,int16,sizeof(smallint));
          lEEG.Samples[c][s]:= int16;
        end;
    end else begin //not a vector
      for S := 0 to NS - 1 do
        for C := 0 to NC - 1 do begin
          blockread(fp,int16,sizeof(smallint));
          lEEG.Samples[c][s]:= int16;
        end;
    end;
  end;
  CloseFile(fp);
  result := true;
end;

function CountBinary (lFilename: string; NC, lFormat: integer; VECTORIZED: boolean): integer;
var
  fp: file;
begin
  result := 0;
  if not fileexists(lFilename) then begin
    showmessage('Can not find file '+lFilename);
    exit;
  end;
  if (NC < 1) then
    exit;
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Reset(fp, 1);
  result :=  filesize(fp) div (NC*abs(lFormat div 8));
  CloseFile(fp);
end;


function LoadASCII (lFilename: string; var lEEG: TEEG; NC,NS, lPadRow,lPadCol: integer; VECTORIZED: boolean): boolean;
var
  fp: textfile;
  S,C,P: integer;
  pad: single;
begin
  result := false;
  if not fileexists(lFileName) then begin
    showmessage('Can not find '+lFilename);
    exit;
  end;
  if (NC < 1) or (NS < 1) then
    exit;
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Reset(fp);
  if lPadRow > 0 then
    for P := 1 to lPadRow do
      Readln(fp);
  if  VECTORIZED then begin
    for C := 0 to NC - 1 do begin
      if lPadCol > 0 then
        for P := 1 to lPadCol do
          Read(fp,Pad);
      for S := 0 to NS - 1 do
        read(fp,lEEG.Samples[c][0]);
      readln(fp);
    end;
  end else begin //not a vector
      for S := 0 to NS - 1 do begin
        if lPadCol > 0 then
          for P := 1 to lPadCol do
            Read(fp,Pad);
        for C := 0 to NC - 1 do
          read(fp,lEEG.Samples[c][s]);
        readln(fp);
      end;
  end;
  CloseFile(fp);
  result := true;
end;

function FirstCSV(lStr: string): string;
//reports text prior to comma...
var
  i,len: integer;
begin
  result := '';
  len := length(lStr);
  if len < 1 then exit;
  for i := 1 to len do begin
    if lStr[i] = ',' then
      exit;
    result := result + lStr[i];
  end;
end;

function LastCSV(lStr: string): string;
//reports text prior to comma...
var
  i,len: integer;
begin
  result := '';
  len := length(lStr);
  if len < 1 then exit;
  for i := len downto 1 do begin
    if lStr[i] = ',' then
      exit;
    result := lStr[i]+result;
  end;
end;

function CountASCII (lFilename: string; NC, lPadRow,lPadCol: integer; VECTORIZED: boolean): integer;
var
  V: single;
  fp: textfile;
  C,P: integer;
  Abort: boolean;
  lNumStr: string;
begin
  result := 0;
  if not fileexists(lFileName) then begin
    showmessage('Can not find '+lFilename);
    exit;
  end;
  if (NC < 1) then
    exit;
  FileMode := 2; //set to read/write
  AssignFile(fp, lFileName);
  Reset(fp);
  if lPadRow > 0 then
    for P := 1 to lPadRow do
      Readln(fp);
  Abort := false;
  if  VECTORIZED then begin
    for C := 0 to NC - 1 do begin
      if lPadCol > 0 then
        for P := 1 to lPadCol do
          Read(fp,V);
      repeat
        read(fp,lNumStr);
        if lNumStr = '' then begin
              Abort := true;
        end else begin
             try
               V := strtofloat(lNumStr);
             except
              on EConvertError do
                Abort := true;
             end;
         end;
         if not Abort then
          inc(result);

      until Abort;
    end;
  end else begin //not a vector
      repeat
      //for S := 0 to NS - 1 do begin
         if lPadCol > 0 then
          for P := 1 to lPadCol do
            Read(fp,V);
         for C := 0 to NC - 1 do begin
            read(fp,lNumStr);
            if lNumStr = '' then begin
              Abort := true;
            end else begin
             try
              V := strtofloat(lNumStr);
             except
              on EConvertError do
                Abort := true;
             end;
            end;
         end;
         if not Abort then
          inc(result);
         readln(fp);
      until Abort or EOF(fp);
  end;
  CloseFile(fp);
end;

function LoadVHDR(lFilename: string; var  lEEG: TEEG): boolean;
//Read or write initialization variables to disk
var
  lIniFile: TIniFile;
  lC,lNC,lNS,lType,lPadRow,lPadCol: integer;
  lDatName,S: string;
  lVectorized,lBinary: boolean;
  lSR : double;
begin
  result := false;
  //defaults...
  lType := -16;// default is signed INT_16
  lPadRow := 0;
  lPadCol := 0;
  //read name of data file
  lIniFile := TIniFile.Create(lFilename);
  lDatName := RIniStr(lIniFile, 'Common Infos','DataFile',lDatName);
  lDatName := AnsiReplaceStr(lDatName, '$b', ChangeFileExt(ExtractFileName(lFilename), '')) ;
  if not DirectoryExists(extractfiledir(lDatName)) then begin
    S := extractfiledir(lFilename);
    if (length(S) > 1) and (S[length(S)] <> pathdelim) then
      S := S + pathdelim;
    lDatName := S+lDatName;
  end;
  //IniStr(lRead,lIniFile, 'Common Infos','MarkerFile',lFName);
  S := RIniStr(lIniFile, 'Common Infos','DataFormat','ASCII');
  lBinary := (upcase(S[1]) = 'B');
  S := RIniStr(lIniFile, 'Common Infos','DataOrientation','MULTIPLEXED');
  lVectorized := (upcase(S[1]) = 'V');
  S := RIniStr(lIniFile, 'Common Infos','DataType','TIMEDOMAIN');//not FREQUENCYDOMAIN
  if upcase(S[1]) = 'F' then
    showmessage('VHDR Error: this software reads data in the time domain, but data is in frequency domain.');

  lNC := RIniInt(lIniFile, 'Common Infos','NumberOfChannels',-1);
  if lNC < 1 then begin
    showmessage('VHDR Error: number of data channels not specified.');
    exit;
  end;
  lSR := RIniDouble(lIniFile, 'Common Infos','SamplingInterval',-1);// convert Hz to MICROsec
  if lSR < 0.1 then begin
    showmessage('VHDR Error: SamplingInterval not specified.');
    exit;
  end;
  lSR :=  1000000/lSR; //microsec to hz 1,000,000 ms per sec
  lNS := RIniInt(lIniFile, 'Common Infos','DataPoints',0);
  if not lBinary then begin
    S := RIniStr(lIniFile, 'ASCII Infos','DecimalSymbol','.');
    if length(S) > 1 then
      decimalseparator := S[1];
    lPadRow := RIniInt(lIniFile, 'Common Infos','SkipLines',0);
    lPadCol := RIniInt(lIniFile, 'Common Infos','SkipColumns',0);
  end else begin
    S := RIniStr(lIniFile, 'Binary Infos','BinaryFormat','INT_16');
    lType := -16;// default is signed INT_16
    if (length(S) > 1) then begin
      if (S[2]='E') then
        lType := 32  //IEEE_FLOAT_32
      else if (S[2]='I') then
        lType := 16;//UINT_16
    end;
    {RIniInt(lIniFile, 'Binary Infos','ChannelOffset',0);
    RIniInt(lIniFile, 'Binary Infos','DataOffset',0);
    RIniInt(lIniFile, 'Binary Infos','SegmentHeaderSize',0);
    RIniInt(lIniFile, 'Binary Infos','TrailerSize',0);
    RIniStr(lIniFile, 'Binary Infos','UseBigEndianOrder','NO');}
  end;

  if lNS < 1 then begin
    if  lbinary then
      lNS := CountBinary(lDatName, lNC,  lType, lVectorized)
    else
      lNS := CountASCII (lDatName, lNC, lPadRow,lPadCol,lVectorized);
    if lNS < 1 then begin
      showmessage('This software currently only supports VHDR files that explicitly report the DataPoints.');
      exit;
    end;
  end;
  CreateEEG(lEEG, lNC,lNS,lSR);
  for lC := 1 to NumChannels(lEEG) do begin
    S := RIniStr(lIniFile, 'Channel Infos','Ch'+inttostr(lC),'Ch'+inttostr(lC));
    lEEG.channels[lC-1].Info := FirstCSV(S);
    S := LastCSV(S);
    if (length(S) > 1) and  (Upcase(S[1])='D') then //digital
      lEEG.channels[lC-1].SignalLead := false
    else
      lEEG.channels[lC-1].SignalLead := true;
  end;
  lIniFile.Free;
  lEEG.DataFile := lDatName;
  lEEG.Time := Now;
  if  lbinary then
    result := LoadBinary(lDatName, lEEG, lNC, lNS, lType, lVectorized)
  else
    result := LoadASCII(lDatName, lEEG, lNC, lNS, lPadRow, lPadCol, lVectorized) ;
end;



end.
