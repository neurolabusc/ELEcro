unit filter_all;

interface
uses eeg_type, filter_bw, dialogs, sysutils, prefs,filter_rbj;
procedure AddTriggers (var lEEG: TEEG; lChannel: integer; lHz,lAmplitude,lDurationMS, PhaseFrac: single);
procedure AddSineWave (var lEEG: TEEG;  lHz,lAmplitude: single); overload;
procedure AddSineWave (var lEEG: TEEG; lChannel: integer; lHz,lAmplitude: single); overload;
procedure AddSlope (var lEEG: TEEG; lChannel: integer; lAmplitude: single);
procedure LowPass (var lEEG: TEEG; lHz: integer); overload;
procedure LowPass (var lEEG: TEEG; lChannel: integer; lHz: integer); overload;
procedure HighPass (var lEEG: TEEG; lHz: integer); overload;
procedure HighPass (var lEEG: TEEG; lChannel: integer; lHz: integer); overload;
procedure FilterRBJ (lEEG: TEEG;  lPrefs: TFilter);  overload;
procedure FilterRBJ (lEEG: TEEG; lChannel: integer; lPrefs: TFilter);  overload;
procedure FilterZeroMean (lEEG: TEEG; lChannel: integer); overload;
procedure FilterZeroMean (lEEG: TEEG); overload;
implementation

procedure FilterZeroMean (lEEG: TEEG; lChannel: integer); overload;
var
  sum: double;
  ns,s: integer;
begin
    ns := NumSamples(lEEG,lChannel);
   if (not (lEEG.Channels[lChannel].SignalLead)) or (ns < 2) then
    exit;
    sum := 0;
   for s := 0 to ns-1 do
    sum :=  sum + lEEG.Samples[lChannel][s];
   sum := sum/ns;
   for s := ns-1 downto 0 do
    lEEG.Samples[lChannel][s] :=  lEEG.Samples[lChannel][s]-sum;
end;


procedure FilterZeroMean (lEEG: TEEG); overload;
var
 c: integer;
begin
  if NumChannels(lEEG) < 1 then
    exit;
   lEEG.FiltersApplied := lEEG.FiltersApplied + 'ZeroMean'{+inttostr(lChannel)};
  for c := 0 to NumChannels(lEEG)-1 do
      FilterZeroMean(lEEG,c);
end;

procedure AddSlope (var lEEG: TEEG; lChannel: integer; lAmplitude: single);
var
  ns,i: integer;
begin
    ns := NumSamples(lEEG,lChannel);
    if ns < 1 then
       exit;
    for i := 0 to ns-1 do
        lEEG.Samples[lChannel][i] := lEEG.Samples[lChannel][i]+ (i/(ns-1))*lAmplitude;
end;

procedure AddTriggers (var lEEG: TEEG; lChannel: integer; lHz,lAmplitude,lDurationMS, PhaseFrac: single);
var
period: single;
  dur,ns,m,i,d: integer;
begin
    if lHz = 0 then
       exit;
    ns := NumSamples(lEEG,lChannel);
    if {(lEEG.Channels[lChannel].SignalLead) and} (ns>0) then begin
      dur := round (lDurationMS/1000*lEEG.Channels[lChannel].SampleRate);
      if dur < 1 then
        dur := 1;
      period :=  abs(lEEG.Channels[lChannel].SampleRate/lHz);//abs just in case negative Hz
      i := round(period + (period*PhaseFrac));
      m := 1;
      while i < (ns-1) do begin
            for d := 0 to dur-1 do
              if (d+i) < ns then
                lEEG.Samples[lChannel][d+i] := lEEG.Samples[lChannel][d+i]+lAmplitude;
            inc(m);
            i := round(m*period+ (period*PhaseFrac));
      end;
    end;//signal lead
end;

procedure AddSineWave (var lEEG: TEEG; lChannel: integer; lHz,lAmplitude: single);
var
period: single;
  ns,s: integer;
begin
    if lHz = 0 then
       exit;
    ns := NumSamples(lEEG,lChannel);
    if (lEEG.Channels[lChannel].SignalLead) and (ns>0) then begin
      period :=  lEEG.Channels[lChannel].SampleRate/abs(lHz);
      for s := 0 to ns-1 do
       lEEG.Samples[lChannel][s] := lEEG.Samples[lChannel][s]+(lAmplitude * sin (s * 2.0 * pi / period));
    end;//signal lead
end;

procedure AddSineWave (var lEEG: TEEG;  lHz,lAmplitude: single);
var
 c: integer;
begin
  for c := 0 to NumChannels(lEEG)-1 do
      AddSineWave(lEEG,c,lHz,lAmplitude);
end;

procedure BWFilter (var lEEG: TEEG; lChannel: integer; lHz: integer; Lowpass: boolean); overload;
var
  ns: integer;
begin
    if lHz = 0 then
       exit;
    ns := NumSamples(lEEG,lChannel);
    if (lEEG.Channels[lChannel].SignalLead) and (ns>0) then begin
      xButterworth(lEEG.Samples[lChannel], lEEG.Channels[lChannel].SampleRate, lHz,Lowpass);
    end;//signal lead
end;

procedure LowPass (var lEEG: TEEG; lChannel: integer; lHz: integer); overload;
begin
  BWFilter(lEEG,lChannel,lHz,true);
end;

procedure LowPass (var lEEG: TEEG;  lHz: integer); overload;
var
 c: integer;
begin
  for c := 0 to NumChannels(lEEG)-1 do
      LowPass(lEEG,c,lHz);
end;

procedure HighPass (var lEEG: TEEG; lChannel: integer; lHz: integer); overload;
begin
  BWFilter(lEEG,lChannel,lHz,false);
end;

procedure HighPass (var lEEG: TEEG;  lHz: integer); overload;
var
 c: integer;
begin
  for c := 0 to NumChannels(lEEG)-1 do
      HighPass(lEEG,c,lHz);
end;

procedure FilterRBJ (lEEG: TEEG; lChannel: integer; lPrefs: TFilter);  overload;
var
  lF: TRbjEqFilter;
  ns,s: integer;
begin
    ns := NumSamples(lEEG,lChannel);
   if (not (lEEG.Channels[lChannel].SignalLead)) or (ns < 2) then
    exit;
   lF  := TRbjEqFilter.Create(ChannelSampleRate(lEEG, lChannel),8000);
   lF.CalcFilterCoeffs(lPrefs.FiltType,lPrefs.FiltHz,lPrefs.FiltQ{Q},lPrefs.FiltDBGain, lPrefs.FiltQIsBandWidth);
   for s := 0 to ns-1 do
    lEEG.Samples[lChannel][s] :=  lF.Process(lEEG.Samples[lChannel][s]);
   if not lPrefs.FiltBidirectional then
    exit;
   lF.CalcFilterCoeffs(lPrefs.FiltType,lPrefs.FiltHz,lPrefs.FiltQ{Q},lPrefs.FiltDBGain, lPrefs.FiltQIsBandWidth);
   for s := ns-1 downto 0 do
    lEEG.Samples[lChannel][s] :=  lF.Process(lEEG.Samples[lChannel][s]);
end;

procedure FilterRBJ (lEEG: TEEG;  lPrefs: TFilter);  overload;
var
 c: integer;
begin
  if NumChannels(lEEG) < 1 then
    exit;
   lEEG.FiltersApplied := lEEG.FiltersApplied + FilterName(lPrefs.FiltType){+':Channel'+inttostr(lChannel)}
    +':Hz'+floattostr(lPrefs.FiltHz)+':dBGain'+floattostr(lPrefs.FiltDBGain)+':Q'+floattostr(lPrefs.FiltQ)+' ';
  for c := 0 to NumChannels(lEEG)-1 do
      FilterRBJ(lEEG,c,lPrefs);
end;

end.

