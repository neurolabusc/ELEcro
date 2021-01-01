unit tool_sound;
interface
uses
{$IFDEF Win32}
  Dialogs,Windows, ShellAPI, Messages, MMSystem,
{$ELSE}
  LMessages, LCLType,
{$ENDIF}
math,  Classes, SysUtils, eeg_type;

procedure PlaySoundX;
procedure StopSoundX;
procedure CreateSound (lEEG: TEEG; lChannel, lStartSample,lDurationMS: integer);


implementation

{$IFNDEF Win32}
procedure PlaySoundX;
begin
//
end;

procedure StopSoundX;
begin
//
end;

procedure CreateSound (lEEG: TEEG; lChannel, lStartSample,lDurationMS: integer);
begin
//
end;

{$ELSE}
  const
  Mono: Word = $0001;
  
  RiffId: string = 'RIFF';
  WaveId: string = 'WAVE';
  FmtId: string = 'fmt ';
  DataId: string = 'data';
var
     MS:tmemorystream;



 procedure PlaySoundX;
 var options:integer;
 begin
   if not assigned (ms) then
    exit;
   options:=SND_MEMORY or SND_ASYNC;
   //if duration.position=0 then
      options:=options or SND_LOOP;
   PlaySound(MS.Memory, 0, options);
 end;


procedure StopSoundX;
begin
  PlaySound(nil,0,SND_Purge);
  if assigned (ms) then freeandnil(Ms);
end;


procedure CreateSound (lEEG: TEEG; lChannel, lStartSample,lDurationMS: integer);
procedure MinMax (lV: single; var lMin,lMax: single);
begin
  if lV < lMin then lMin := lV;
  if lV > lMax then lMax := lV;
end;
var
  WaveFormatEx: TWaveFormatEx;
  c,samplerate, i, TempInt, RiffCount, datacount:integer;
  Byteval:byte;
  min,max,scale: single;
begin
  if NumSamples (lEEG, lChannel)< 1 then
    exit;
  c := lChannel-1;//arrays indexed from 0
  SampleRate := round(lEEG.Channels[c].SampleRate);
  DataCount := (lDurationMS * SampleRate) div 1000; {record "duration" ms at "samplrate" samps/sec}
  if (DataCount < 1) or (NumSamples (lEEG, lChannel)< (lStartSample+DataCount)) then
    exit;
  max := lEEG.Samples[c][lStartSample];
  min :=  lEEG.Samples[c][lStartSample];
  for i := 0 to DataCount-1 do
    minmax(lEEG.Samples[c][lStartSample+i],Min,Max);
  scale := max-min;//range
  if scale <= 0 then
    exit;
  scale := 255/max;
  with WaveFormatEx do begin
      wFormatTag := WAVE_FORMAT_PCM;
      nChannels := Mono;
      nSamplesPerSec := SampleRate;
      wBitsPerSample := $0008;
      nBlockAlign := (nChannels * wBitsPerSample) div 8;
      nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
      cbSize := 0;
  end;
    MS := TMemoryStream.Create;
    {Calculate length of sound data and of file data}
    DataCount := (lDurationMS * SampleRate) div 1000; {record "duration" ms at "samplrate" samps/sec}
    RiffCount := Length(WaveId) + Length(FmtId) + SizeOf(DWORD) +
    SizeOf(TWaveFormatEx) + Length(DataId) + SizeOf(DWORD) + DataCount; // file data
    {write out the wave header}
    MS.Write(RiffId[1], 4); // 'RIFF'
    MS.Write(RiffCount, SizeOf(DWORD)); // file data size
    MS.Write(WaveId[1], Length(WaveId)); // 'WAVE'
    MS.Write(FmtId[1], Length(FmtId)); // 'fmt '
    TempInt := SizeOf(TWaveFormatEx);
    MS.Write(TempInt, SizeOf(DWORD)); // TWaveFormat data size
    MS.Write(WaveFormatEx, SizeOf(TWaveFormatEx)); // WaveFormatEx record
    MS.Write(DataId[1], Length(DataId)); // 'data'
    MS.Write(DataCount, SizeOf(DWORD)); // sound data size
    {calculate and write out the tone signal} // now the data values
    for i := 0 to DataCount-1 do begin
      Byteval := round((lEEG.Samples[c][lStartSample+i]-Min)*scale);
      MS.Write(Byteval, SizeOf(Byte));
    end;
    PlaySoundX;
end;


{$ENDIF}


end.
