 unit eeg_type;
 interface
 uses deb;
 type
  TChannel = record
      SignalLead,Visible: boolean;
      Info,UnitType: string;  
      DisplayScale,SampleRate : double;
   end;
  TEEG = record
      DataFile: string;
      FiltersApplied: string;
      Time: TDateTime;
      Channels: array of TChannel;
      Samples: array of array of single;
   end;
 function ChannelSampleRate (lEEG:TEEG; lChannel: integer): double;
 function SampleRateZeroIfVariable (lEEG: TEEG): double;
 function ChannelName (lEEG:TEEG; lChannel: integer): string;
 procedure CreateEEG(var lEEG: TEEG; lChannels,lSamples: integer); overload;
 procedure CreateEEG(var lEEG: TEEG; lChannels,lSamples: integer; lSampleRate: double); overload;
 function NumChannels (lEEG: TEEG): integer;
 function NumSignalChannels (lEEG: TEEG): integer;
 function NumVisibleChannels (lEEG: TEEG): integer;
 function AllChannelsSameLengthSR (lEEG: TEEG): boolean;
 function NumSamples (lEEG: TEEG; lChannel: integer): integer;
 function MaxNumSamples (lEEG: TEEG): integer;
 function NumSamplesZeroIfVariable (lEEG: TEEG): integer;
 function TotalNumSamples (lEEG: TEEG): integer;
 function AbsoluteMaxInterval (lEEG: TEEG):single; overload;
 function AbsoluteMaxInterval (lEEG: TEEG; lChannel: integer):single; overload;
 procedure AutoScaleEEG(var lEEG: TEEG; lChannel: integer; Max: Single);
 procedure ClearEEGHdr (var lEEG: TEEG);
 procedure CopyEEG (var lSource,lDest: TEEG);
implementation

procedure CopyEEG (var lSource,lDest: TEEG);
var
  s,c,nc,ns: integer;
begin
  setlength(lDest.Channels,NumChannels(lSource));
  ClearEEGHdr ( lDest);
  lDest.Time := lSource.Time;
  nc := NumChannels(lSource);
  if  nc < 1 then begin
    lDest.Samples := nil;
    exit;
  end;
  for c := 1 to nc do begin
    lDest.Channels[c-1] := lSource.Channels[c-1];
    ns := NumSamples(lSource,c-1);
    setlength(lDest.Samples,c,ns);
    for s := 0 to ns-1 do
      lDest.Samples[c-1][s] := lSource.Samples[c-1][s];
  end;
end;

function ChannelSampleRate (lEEG:TEEG; lChannel: integer): double;
begin
  result := 1;
  if lChannel < 0 then exit;
  if lChannel >= NumChannels(lEEG) then exit;
  result := lEEG.Channels[lChannel].SampleRate;
end;

function SampleRateZeroIfVariable (lEEG: TEEG): double;
var
  v: double;
   c,i:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  v :=  ChannelSampleRate(lEEG,0);
  for i := 0 to (c-1) do
      if ChannelSampleRate(lEEG,i) <> v then
         exit;
  result := v;
end;

function ChannelName (lEEG:TEEG; lChannel: integer): string;
begin
  result := '';
  if lChannel < 0 then exit;
  if lChannel >= NumChannels(lEEG) then exit;
  result := lEEG.Channels[lChannel].Info;
end;

procedure ClearEEGHdr (var lEEG: TEEG);
var
  i: integer;
begin
  if NumChannels(lEEG) < 1 then exit;
  lEEG.FiltersApplied := '';
  for i := 0 to NumChannels(lEEG)-1 do begin
    with lEEG.Channels[i] do begin
      SignalLead := true;
      Visible := true;
      DisplayScale := 1;
      Info := 'N/A';
      SampleRate := 1024;
    end;
  end;
end;
(*  CreateEEG(lEEG,c,k);
  for i := 0 to c - 1 do begin
    with lEEG.Channels[i] do begin
      SignalLead := true;
      DisplayScale := 1;
      Info := 'xxx';
      SampleRate := 1024;
    end;
  end;
end;  *)
procedure CreateEEG(var lEEG: TEEG; lChannels,lSamples: integer);  overload;
begin
  if (lChannels < 1) or (lSamples < 1) then
    exit;
  setlength(lEEG.Channels,lChannels);
  ClearEEGHdr ( lEEG);
  setlength(lEEG.Samples,lChannels,lSamples);
end;

 procedure CreateEEG(var lEEG: TEEG; lChannels,lSamples: integer; lSampleRate: double); overload;
 var
  i: integer;
 begin
  if (lChannels < 1) or (lSamples < 1) then
    exit;
  CreateEEG(lEEG,lChannels,lSamples);

  for i := 0 to (lChannels-1) do begin
    lEEG.Channels[i].SignalLead := true;
    lEEG.Channels[i].SampleRate := lSampleRate;
  end;
end;

function NumChannels (lEEG: TEEG): integer;
begin
    result := length(lEEG.channels);
end;

function NumVisibleChannels (lEEG: TEEG): integer;
var
   c,i:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  for i := 0 to (c-1) do
      if (lEEG.Channels[i].Visible) and (length(lEEG.Samples[i]) > 0) then
         inc(result);
end;

function NumSignalChannels (lEEG: TEEG): integer;
var
   c,i:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  for i := 0 to (c-1) do
      if (lEEG.Channels[i].SignalLead) and (length(lEEG.Samples[i]) > 0) then
         inc(result);
end;

function AllChannelsSameLengthSR (lEEG: TEEG): boolean;
var
   sr: double;
   c,i,len:integer;
begin
  sr := -1;
  len := -1;
  result := false;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  for i := 0 to (c-1) do begin
      //if (lEEG.Channels[i].SignalLead) then begin
        if len < 0 then begin
          len := length(lEEG.Samples[i]);
          sr := lEEG.Channels[i].samplerate;
        end else if (length(lEEG.Samples[i]) <> len)
          or (sr <> lEEG.Channels[i].samplerate) then
          exit;                             
      //end;
  end;
  if len < 1 then
    exit;
  result := true;
end;


function NumSamples (lEEG: TEEG; lChannel: integer): integer;
begin
    if (lChannel < 0) or (lChannel >= NumChannels(lEEG)) then
      result := 0
    else
      result := length(lEEG.Samples[lChannel]);
end;

function MaxNumSamples (lEEG: TEEG): integer;
var
   c,i:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  for i := 0 to (c-1) do
      if length(lEEG.Samples[i]) > result then
         result := length(lEEG.Samples[i]);
end;


function NumSamplesZeroIfVariable (lEEG: TEEG): integer;
var
   c,i,v:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  v :=  length(lEEG.Samples[0]);
  for i := 0 to (c-1) do
      if length(lEEG.Samples[i]) <> v then
         exit;
  result := v;
end;

function TotalNumSamples (lEEG: TEEG): integer;
var
   c,i:integer;
begin
  result := 0;
  c := NumChannels(lEEG);
  if c < 1 then
     exit;
  for i := 0 to (c-1) do
      result := result + length(lEEG.Samples[i]);
end;


function AbsoluteMaxInterval (lEEG: TEEG; lChannel: integer):single; overload;
var
   i,samp: integer;
   s: single;
begin
    result := 0;
    samp := NumSamples(lEEG,lChannel);
    if samp < 1 then
       exit;
    result := abs(lEEG.Samples[lChannel][0]);
    for i := 0 to samp -1 do begin
        s := abs(lEEG.Samples[lChannel][i]);
        if s > result then
           result := s;
    end;
end;

function AbsoluteMaxInterval (lEEG: TEEG):single; overload;
var
   i,c: integer;
   s: single;
begin
    result := 0;
    c := NumChannels(lEEG);
    if c < 1 then
         exit;
    result := AbsoluteMaxInterval(lEEG,0);
    if c = 1 then
       exit;
    for i := 1 to c-1 do begin
        s := AbsoluteMaxInterval(lEEG,i);
        if s > result then
           result := s;
    end;
end;

procedure AutoScaleEEG(var lEEG: TEEG; lChannel: integer; Max: Single);
var
  A : Single;
begin
  if  NumSamples(lEEG,lChannel) < 1 then
  exit;
  A:=AbsoluteMaxInterval(lEEG,lChannel);
  if A<>0 then lEEG.Channels[lChannel].DisplayScale:=Max/A;
end;

 end.
