unit ave;
interface
uses eeg_type,dialogs,sysutils, math, deb, classes, clipbrd,format_vmrk, prefs;
//procedure Average (var lEEG: TEEG; lTriggerChannel,AvePre,AvePost,AvePulseTime,lThreshInt: integer);
//procedure Trigger2Event (var lEEG: TEEG; lTriggerChannel,AvePulseTime,lThreshInt: integer);
procedure Trigger2Event (var lEEG: TEEG; lTriggerChannel,AvePulseTime,lThreshInt,AveIgnore: integer; var lV: TVMRK);
procedure Average (var lEEG: TEEG; var lV: TVMRK; lPrefs: TPrefs; lFilename: string);
//remove duplicate strings from the string list
 procedure RemoveDuplicates(const stringList : TStringList) ;
function IntToThresh (ThreshInt: integer): single;
//function Time2Cond (lDurationSamples: integer;  AvePulseTimesamples: single): integer;
implementation

const
  kInf : double = 1/0;
type
  TDoubleRA = array of double;


  

function IntToThresh (ThreshInt: integer): single;
begin
  if ThreshInt > 0 then
    result := ThreshInt
  else if ThreshInt = 0 then
    result := 0.5
  else
    result := power(10,ThreshInt);
end;

function ComputeBaseline (var lSourceEEG: array of single; l1stSample, lBaselineSamples,lonsetshiftsamples: integer): double;
var
  i: integer;
begin
  result := 0;
  if (lBaselineSamples < 1) or ((l1stSample-lBaselineSamples-lonsetshiftsamples) < 0) or (l1stSample>= length(lSourceEEG)) then
    exit;

  for i := 1 to lBaselineSamples do
      result := result + lSourceEEG[l1stSample-i-lonsetshiftsamples];
    result := result / lBaselineSamples;
end;

procedure Add2Ave(var lSourceEEG,lAveEEG: array of single; l1stSample,lnSamples,lBaselineSamples,lonsetshiftsamples: integer; var lnOK: integer; lRectify: boolean);
var
  i: integer;
  meanbaseline : double;
begin
  if (l1stSample < 0) or (lnSamples < 1) then
    exit;
  if (l1stSample+lnSamples)>= length(lSourceEEG) then
    exit;
  meanbaseline := ComputeBaseline (lSourceEEG,l1stSample, lBaselineSamples,lonsetshiftsamples);
  if lRectify then
    for i := 0 to lnSamples-1 do
      lAveEEG[i] := lAveEEG[i]+abs(lSourceEEG[i+l1stSample]-meanbaseline)
  else
    for i := 0 to lnSamples-1 do
      lAveEEG[i] := lAveEEG[i]+lSourceEEG[i+l1stSample]-meanbaseline;
  inc(lnOK);
end;

procedure InitMinMax (lV: double; var lMin,lMax: double);  overload;
begin
    lMin := lV;
    lMax := lV;
end;

procedure MinMax (lV: double; var lMin,lMax: double);  overload;
begin
  if lV < lMin then
    lMin := lV;
  if lV > lMax then
    lMax := lV;
end;

procedure InitMinMax (lV: single; var lMin,lMax: single);  overload;
begin
    lMin := lV;
    lMax := lV;
end;

procedure MinMax (lV: single; var lMin,lMax: single);  overload;
begin
  if lV < lMin then
    lMin := lV;
  if lV > lMax then
    lMax := lV;
end;

procedure InitMinMax (lV: integer; var lMin,lMax: integer);  overload;
begin
    lMin := lV;
    lMax := lV;
end;

procedure MinMax (lV: integer; var lMin,lMax: integer);  overload;
begin
  if lV < lMin then
    lMin := lV;
  if lV > lMax then
    lMax := lV;
end;

type
  TStat = record
    min,max,range,mean: double;
    //cond: integer;
  end;

function ClearStat: TStat;
begin
  result.min := 0;
  result.max := 0;
  result.range := 0;
  result.mean := 0;
end;


procedure ComputeStats(var lSourceEEG: array of single; l1stSample,lnSamples,lBaslineSamples,lonsetshiftsamples: integer; var lStat: TStat);
var
  lBaseline: double;
  i: integer;
begin
  lStat := ClearStat;
  if (l1stSample < 0) or (lnSamples < 1) then
    exit;
  if (l1stSample+lnSamples)>= length(lSourceEEG) then
    exit;
  lBaseline := ComputeBaseline(lSourceEEG,l1stSample,lBaslineSamples,lonsetshiftsamples);
  InitMinMax( lSourceEEG[l1stSample]-lBaseline,lStat.Min,lStat.Max);
  for i := 0 to lnSamples-1 do
    MinMax(lSourceEEG[i+l1stSample]-lBaseline,lStat.Min,lStat.Max);
  lStat.Range := lStat.Max-lStat.Min;
  lStat.mean := 0;
  for i := 0 to lnSamples-1 do
    lStat.mean := lStat.mean + lSourceEEG[i+l1stSample]-lBaseline;
  lStat.mean := lStat.mean / lnSamples;
end;

procedure ComputeStatsAbs(var lSourceEEG: array of single; l1stSample,lnSamples,lBaslineSamples,lonsetshiftsamples: integer; var lStat: TStat);
var
  lBaseline: double;
  i: integer;
begin
  lStat := ClearStat;
  if (l1stSample < 0) or (lnSamples < 1) then
    exit;
  if (l1stSample+lnSamples)>= length(lSourceEEG) then
    exit;
  lBaseline := ComputeBaseline(lSourceEEG,l1stSample,lBaslineSamples,lonsetshiftsamples);
  InitMinMax( Abs(lSourceEEG[l1stSample]-lBaseline),lStat.Min,lStat.Max);
  for i := 0 to lnSamples-1 do
    MinMax(Abs(lSourceEEG[i+l1stSample]-lBaseline),lStat.Min,lStat.Max);
  lStat.Range := lStat.Max-lStat.Min;
  lStat.mean := 0;
  for i := 0 to lnSamples-1 do
    lStat.mean := lStat.mean + abs(lSourceEEG[i+l1stSample]-lBaseline);
  lStat.mean := lStat.mean / lnSamples;
end;

function Time2Cond (lDurationSamples: integer;  AvePulseTimesamples: single): integer;
//if avePulseTimeSamples = 10, then 0..14=Cond1, 15..25=Cond2, 26..34=Cond3... etc
//note rounding uses bankers rules, e.g. rounds to nearest even integer
begin
  //fx(lDurationSamples {+AvePulseTimesamples/2} ,AvePulseTimesamples);
  result := round((lDurationSamples {+(AvePulseTimesamples/2)})/AvePulseTimesamples);
  if result < 1 then
    result := 1;
end;




(*procedure CompileStats (var lEEG: TEEG; var lonset,lduration: array of integer; lavesamples: integer; AvePulseTimesamples: single);
const
  kTab = chr(9);
var
  StatRA: array of TStat;
  i,all,chan,nt,t,ncs,nc: integer;
  lVMRK,lStrings: TStringList;
  lFilename: string;
begin
  nt := length(lOnset);
  nc := NumChannels(lEEG);
  ncs := NumSignalChannels(lEEG);
  if (nt < 1) or (length(lduration)<> nt) or (ncs < 1) or (nc < ncs) then
    exit;
  //maximum trigger duration....
  setlength (StatRA,nt);
  chan := 0;
  lStrings := TStringList.Create;
  lStrings.Add('Peak data for '+inttostr(lavesamples)+' samples');
  lVMRK := TStringList.Create;
  lVMRK.Add('Brain Vision Data Exchange Marker File, Version 1.0');
  lVMRK.Add('[Common Infos]');
  lVMRK.Add('DataFile=lefthemitms.vhdr');
  lVMRK.Add('[Marker Infos]');
  lVMRK.Add('; Each entry: Mk{Marker number}={Type},{Description},{Position in data points},');
  lVMRK.Add('; {Size in data points}, {Trace number (0 = marker is related to all Traces)}');
  lVMRK.Add('; Fields are delimited by commas, some fields might be omitted (empty).');
  for all := 0 to ncs-1 do begin
    if (lEEG.Channels[all].SignalLead) then begin
      lStrings.Add('Trial'+kTab+'Channel'+kTab+'Cond'+kTab+'Min'+kTab+'Max'+kTab+'Range'+kTab+'OnsetSample'+kTab+'Duration'  );
      for t := 0 to nt-1 do begin
        StatRA[t].cond := Time2Cond(lduration[t],AvePulseTimesamples);
        ComputeStats(lEEG.samples[all], lonset[t], lavesamples, StatRA[t]);
        //lStrings.Add(floattostr(AvePulseTimesamples)+kTab+inttostr(StatRA[t].cond)+kTab+inttostr(lonset[t])+kTab+inttostr(lduration[t]) );
        lStrings.Add(inttostr(t)+kTab+inttostr(all)+kTab+inttostr(StatRA[t].cond)+kTab+floattostr(StatRA[t].min)+kTab+floattostr(StatRA[t].max)+kTab+floattostr(StatRA[t].max-StatRA[t].min) +kTab+floattostr(lonset[t])+kTab+floattostr(lduration[t])   );
        if chan = 0 then
          lVMRK.Add('Mk'+inttostr(t+1)+'=Stimulus, Cond'+inttostr(StatRA[t].cond)+', '+inttostr(lonset[t])+', '+inttostr(lavesamples)+', 0');
      end;
      //report(lStrings,StatRA,  chan);
      inc(chan);
    end;//if signal lead
   end; //for all channels
   lFilename :=  extractfiledir(paramstr(0))+'\tms_'+ (FormatDateTime('yyyymmdd_hhnnss', (now)))+'.tab';
   lStrings.SaveToFile(lFilename);
   lStrings.free;
   Clipboard.AsText:= lVMRK.Text;
   lVMRK.free;

end;  *)


procedure Trigger2Event (var lEEG: TEEG; lTriggerChannel,AvePulseTime,lThreshInt,AveIgnore: integer; var lV: TVMRK);
var
  lprev,lon: boolean;
  lonset,lduration: array of integer;
  AvePulseTimesamples,lthresh: single;
  AveIgnoreSamples, cond,nt,i,ns,t: integer;

procedure CheckTrig (i: integer; lsample: single);
begin
  lon := lsample > lthresh;
  if lon = lprev then //same state
    exit;
  if lon then begin//new trigger

    lonset[nt] := i;
  end else begin
    lduration[nt] := i-lonset[nt];
    inc(nt);
  end;
  lprev := lon;
end; //nested CheckTrig
begin
   if MaxNumSamples(lEEG) < 2 then begin
    showmessage('Unable to detect event triggers: no polygraphic data is open.');
    exit;
   end;
   AvePulseTimesamples := (AvePulseTime/1000 * lEEG.Channels[0].SampleRate);
   AveIgnoreSamples := abs(round(AveIgnore/1000 * lEEG.Channels[0].SampleRate));
   if AveIgnoreSamples < 0 then
    AveIgnoreSamples := 0;
   if NumSamples(lEEG,lTriggerChannel) < 1 then begin
    showmessage('Trigger channel empty. Channel Requested: '+inttostr(lTriggerchannel)+'  Max Channel'+inttostr(NumChannels(lEEG)));
    exit;
   end;
   if NumSamples(lEEG,lTriggerChannel) < (AveIgnoreSamples*3) then begin
    showmessage('To few samples: either load longer recording or reduce period to ignore at start/end.' );
    exit;
   end;
   //count triggers
   ns := NumSamples(lEEG,lTriggerChannel);
   setlength(lonset,ns div 2); //max half of samples are onsets
   setlength(lduration,ns div 2);
   lthresh := IntToThresh(lThreshInt);
   nt := 0;
   lprev := false;
   lon := false;
   for i :=  AveIgnoreSamples to ns-1-AveIgnoreSamples do
    CheckTrig(i, lEEG.Samples[lTriggerChannel][i]);
  //next- if ended with a pulse, compute duration and onset of final pulse
  if lon then begin//new trigger
    lduration[nt] := ns-1-lonset[nt];
    inc(nt);
  end;
  showmessage('Events: '+inttostr(nt)+' first..last event: '+floattostr(lonset[0]/lEEG.Channels[0].SampleRate)+'..'+floattostr(lonset[nt-1]/lEEG.Channels[0].SampleRate)+' sec');
   //no triggers means no average
   if nt < 1 then begin
    showmessage('No triggers.');
    exit;
   end;
   setlength(lonset,nt); //crop unused channels
   setlength(lduration,nt);
   //text file
   CreateEmptyVMRK(lV,nt);
   lV.Datafile := lEEG.DataFile;
   for t := 0 to nt-1 do begin
    cond := Time2Cond(lduration[t],AvePulseTimesamples);
    lV.Events[t].Desc := 'Cond'+inttostr(cond);
    lV.Events[t].OnsetSamp := lonset[t];
   end;
end;

//remove duplicate strings from the string list
 procedure RemoveDuplicates(const stringList : TStringList) ;
 var
   buffer: TStringList;
   cnt: Integer;
 begin
   stringList.Sort;
   buffer := TStringList.Create;
   try
     buffer.Sorted := True;
     buffer.Duplicates := dupIgnore;
     buffer.BeginUpdate;
     for cnt := 0 to stringList.Count - 1 do
       buffer.Add(stringList[cnt]) ;
     buffer.EndUpdate;
     stringList.Assign(buffer) ;
   finally
     FreeandNil(buffer) ;
   end;
 end;

procedure MinMaxRA(ra: array of integer; var lMin,lMax: integer);
var
  i: integer;
begin
  if length(ra)< 1 then
    exit;
  InitMinMax(ra[0],lMin,lMax);
  for i := 0 to length(ra)-1 do
    MinMax(ra[i],lMin,lMax);
end;

function FloattostrInf (Val: double): string;
begin
  if Val = kInf then
    result := ''
  else
    result := floattostr(Val);
end;

function Mean (Sum: double; N: integer): double;
begin
  if N > 0 then
    result := (Sum/N)
  else
    result := kInf;
end;

function StDev (SumOfSqrs, Sum: double; N: integer): double;
begin
     result := 0;
     if n < 2 then
     	exit;
    result := SumOfSqrs - (Sqr(Sum)/n);
    if  (result > 0) then
        result :=  Sqrt ( result/(n-1))
    else
        result := 0;

end;


function StErr (SumOfSqrs, Sum: double; N: integer): double;
var
  lSD: double;
begin
     result := 0;
     if n < 2 then
     	exit;
     lSD := SumOfSqrs-(Sum*Sum/n);
     if lSD = 0 then
      exit;
     lSD := sqrt(lSD/(n-1) );
     result := lSD/ sqrt(n);
end;

function StErrStr (SumSqr, Sum: double; N: integer): string;
begin
  if N > 1 then
    result := floattostr(StErr(SumSqr,Sum,N))
  else
    result := '';
end;

procedure qsort(lower, upper : integer; var Data: TDoubleRA);
//40ms - very recursive...
var
       left, right : integer;
       pivot,lswap: double;
begin
     pivot:=Data[(lower+upper) div 2];
     left:=lower;
     right:=upper;
     while left<=right do begin
             while Data[left]  < pivot do left:=left+1;  { Parting for left }
             while Data[right] > pivot do right:=right-1;{ Parting for right}
             if left<=right then begin   { Validate the change }
                 lswap := Data[left];
                 Data[left] := Data[right];
                 Data[right] := lswap;
                 left:=left+1;
                 right:=right-1;
             end; //validate
     end;//while left <=right
     if right>lower then qsort(lower,right,Data); { Sort the LEFT  part }
     if upper>left  then qsort(left ,upper,data); { Sort the RIGHT part }
end;

function Median (var dataRA: TDoubleRA; N: integer): double;
var
  Mdn: double;
  M: integer;
begin
   result := 0;
   if N < 3 then
    exit;
   //if N = 4 then qSortx(0,N-1,dataRA);
   qSort(0,N-1,dataRA);
  //if N = 4 then  showmessage('xxx');
   M := (N+1) div 2; //e.g. if three items, median is 2nd ranked
   M := M - 1; //indexed from 0 not 1, so 2nd item has index 1
   Mdn := dataRA[M];
   if not odd(N) then
    Mdn := (Mdn+dataRA[M+1])/2; //e.g. if four items, median is average of 2nd and 3rd ranked
   result := (Mdn);
end;

type
  TStdDev = record
    sum,sumsqr,mean,filtersd,median: double;
    n: integer;
  end;


const
  kFilterSD = 1.96;
    kTab = chr(9);
procedure InitStdDev (var V: TStdDev);
begin
        V.filtersd := kFilterSD;
        V.n := 0;
        V.Sum := 0;
        V.SumSqr := 0;
end;

procedure AddObs (var V: TStdDev; Val: double; var dataRA: TDoubleRA);
begin
  dataRA[V.n] := Val;
  V.n := V.n+1;
  V.Sum := V.Sum + Val;
  V.SumSqr := V.SumSqr + sqr(Val);
end;

procedure ComputeStDev (var V: TStdDev; var dataRA: TDoubleRA);
begin
  V.median := Median(dataRA,V.n );
  V.mean := Mean(V.Sum,V.n);
  V.filtersd := abs(StDev(V.SumSqr,V.Sum,V.n));
end;

procedure ReportStDev (lTitle: string; var V: array of TStdDev; var lStrings,lCondStr: TStringList; nCond: integer);
var
  Cond: integer;
begin
        //lStrings.Add('Mean analysis for channel '+inttostr(all)  );
        lStrings.Add(lTitle);
        lStrings.Add('Cond'+kTab+'CondName'+kTab+'n'+kTab+'Mean'+kTab+'StErr'+kTab+'StDev'+kTab+'Median'  );
        for Cond := 0 to nCond - 1 do
          lStrings.Add(inttostr(Cond+1)+kTab+lCondStr[Cond]+kTab+inttostr(V[Cond].n)+kTab+FloattostrInf(V[cond].mean)+kTab+StErrStr(V[Cond].SumSqr,V[Cond].Sum,V[Cond].n)+kTab+Floattostr(V[Cond].filtersd) +kTab+Floattostr(V[cond].median));
end;

procedure CompileStats (var lEEG: TEEG; var lonset, lcond: array of integer; lCondStr: TStringList; lavesamples,lBaslineSamples,lonsetshiftsamples: integer; AvePulseTimesamples: single; lFilename, lEventFileName: string; lPrefs: TPrefs);
const
  kRaw = 0;
  kFilter = 1;


var
  medianRA,meanmedianRA: TDoubleRA;
  sdRA,meansdRA: array of TStdDev;
  lSR: double;
  Stat: TStat;
  Loop,Filt, Cond,nCond,i,all,nt,t,ncs,nc: integer;
  lStrings: TStringList;
begin
lStrings := TStringList.Create;
  nt := length(lOnset);
  nc := NumChannels(lEEG);
  ncs := NumSignalChannels(lEEG);
  if (nt < 1)  or (ncs < 1) or (nc < ncs) then
    exit;
  minmaxra(lcond,i,nCond);
  if (i <> 1) then begin
    showmessage('CompileStats error: First condition should be 1');
    exit;
  end;
  setlength(sdRA,nCond);
  setlength(meansdRA,nCond);
  setlength (medianRA,nt);
  setlength (meanmedianRA,nt);
  //lStrings := TStringList.Create;
  lStrings.Add('Data for '+kTab+lEEG.DataFile);
  if lPrefs.AveRectify then
    lStrings.Add('Data rectified [absolute values only]')
  else
    lStrings.Add('Data not rectified.');

  if lEEG.FiltersApplied = '' then
    lStrings.Add('Filters Applied:'+kTab+'None(RawData)')
  else
    lStrings.Add('Filters Applied:'+kTab+lEEG.FiltersApplied);
  lSR := SampleRateZeroIfVariable(lEEG);
  if lSR = 0 then
    lStrings.Add('Sample rate '+kTab+'Variable')
  else
    lStrings.Add('Sample rate '+kTab+floattostr(lSR));
  if lEventFileName <> '' then
     lStrings.Add('Event onset file '+kTab+lEventFileName);
  lStrings.Add('Averaging begins '+kTab+inttostr(lPrefs.AveStart)+kTab+'ms relative to stimulus onset (e.g. -10 = 10ms prior to trigger)' );
  lStrings.Add('Averaging for '+kTab+inttostr(lPrefs.AveDuration)+kTab+'ms' );

  if lPrefs.AveRectify then
    lStrings.Add(' Data rectified [absolute voltages]' )
  else
    lStrings.Add(' Data NOT rectified [positive and negative voltages]' );


  lStrings.Add('Peak data for '+kTab+inttostr(lavesamples)+kTab+' samples');

  for all := 0 to nc-1 do begin
    if (lEEG.Channels[all].SignalLead) then begin
     for Loop := kRaw to kRaw do begin
      if Loop = kRaw then
        lStrings.Add('Trial'+kTab+'Channel'+kTab+'Cond'+kTab+'CondName'+kTab+'Min'+kTab+'Mean'+kTab+'Max'+kTab+'Range[peak-to-peak]'+kTab+'OnsetSample'  );
      for Cond := 0 to nCond - 1 do begin
        InitStdDev(sdra[Cond]);
        InitStdDev(meansdra[Cond]);
        //if Loop<> kRaw then
        //  fx(sdra[Cond].mean,sdra[Cond].filtersd);
        for t := 0 to nt-1 do begin
          if Cond = (lCond[t]-1) then begin
              if lPrefs.AveRectify then
                ComputeStatsAbs(lEEG.samples[all], lonset[t], lavesamples, lBaslineSamples,lonsetshiftsamples,Stat)
              else
                ComputeStats(lEEG.samples[all], lonset[t], lavesamples,lBaslineSamples,lonsetshiftsamples, Stat);
              if Loop = kRaw then
                lStrings.Add(inttostr(t)+kTab+inttostr(all)+kTab+inttostr(cond)+kTab+lCondStr[Cond]+kTab+floattostr(Stat.min)+kTab+floattostr(Stat.mean)+kTab+floattostr(Stat.max)+kTab+floattostr(Stat.range) +kTab+floattostr(lonset[t])   );
            if (Loop=kRaw) or ( (sdra[Cond].filtersd <> kInf) and (Stat.range < (sdra[Cond].mean+sdra[Cond].filtersd)) and (Stat.range > (sdra[Cond].mean-sdra[Cond].filtersd))) then begin
              //medianra[sdra[Cond].n] := Stat.range;//
              AddObs(sdRA[Cond],Stat.range,medianra);
              AddObs(meansdRA[Cond],Stat.mean,meanmedianra);
            end; //raw loop or survives filter
          end;//if Cond
          ComputeStDev(sdra[Cond],medianra);
          ComputeStDev(meansdra[Cond],meanmedianra);

          //sdra[Cond].median := Median(medianra,sdra[Cond].n );
          //sdra[Cond].mean := Mean(sdra[Cond].Sum,sdra[Cond].n);
          //sdra[Cond].filtersd := abs(StDev(sdra[Cond].SumSqr,sdra[Cond].Sum,sdra[Cond].n));
        end; //for t all trials
      end;// for Cond all cond
      if Loop = kRaw then begin
         ReportStDev ('Peak-to-peak analysis (raw)', sdra, lStrings,lCondStr,nCond);
         ReportStDev ('Mean analysis (raw)', meansdra, lStrings,lCondStr,nCond);
      end else
         ReportStDev ('Mean analysis  Mean+/- '+floattostr(kFilterSD)+'sd', sdra, lStrings,lCondStr,nCond);

      (*if Loop = kRaw then
        lStrings.Add('Peak-to-peak analysis for channel '+inttostr(all)  )
      else
              lStrings.Add('Filtered Peak-to-peak analysis for channel '+inttostr(all)+' Mean+/- '+floattostr(kFilterSD)+'sd'  );

      lStrings.Add('Cond'+kTab+'CondName'+kTab+'n'+kTab+'Mean'+kTab+'StErr'+kTab+'StDev'+kTab+'Median'  );
      for Cond := 0 to nCond - 1 do
        lStrings.Add(inttostr(Cond+1)+kTab+lCondStr[Cond]+kTab+inttostr(sdra[Cond].n)+kTab+FloattostrInf(sdra[cond].mean)+kTab+StErrStr(sdra[Cond].SumSqr,sdra[Cond].Sum,sdra[Cond].n)+kTab+Floattostr(sdra[Cond].filtersd) +kTab+Floattostr(sdra[cond].median));

      if Loop = kRaw then begin
        lStrings.Add('Mean analysis for channel '+inttostr(all)  );
        lStrings.Add('Cond'+kTab+'CondName'+kTab+'n'+kTab+'Mean'+kTab+'StErr'+kTab+'StDev'+kTab+'Median'  );
        for Cond := 0 to nCond - 1 do
          lStrings.Add(inttostr(Cond+1)+kTab+lCondStr[Cond]+kTab+inttostr(sdra[Cond].n)+kTab+FloattostrInf(sdra[cond].mean)+kTab+StErrStr(sdra[Cond].SumSqr,sdra[Cond].Sum,sdra[Cond].n)+kTab+Floattostr(sdra[Cond].filtersd) +kTab+Floattostr(sdra[cond].median));
      end;  *)
     end; //Loop raw and filtered
    end;//if signal lead
   end; //for all channels
  sdRA := nil;
  meansdRA := nil;
  //medianra := nil;
  if (lFilename <> '') and (lStrings.count > 0) then
   lStrings.SaveToFile(lFilename);
   lStrings.free;
end;

procedure Average (var lEEG: TEEG; var lV: TVMRK; lPrefs: TPrefs; lFilename: string);
var
  lCondStr: TStringList;
  lonset, lCond,averages: array of integer;
  cond, all,c,lavesamples,lonsetshiftsamples, nCond, nsigchan,navechan,t,nt,lBaselineSamples: integer;
  lAveEEG: TEEG;
begin
   if MaxNumSamples(lEEG) < 2 then begin
    showmessage('Unable to generate average: no polygraphic data is open.');
    exit;
   end;
   if not AllChannelsSameLengthSR(lEEG) then begin
    showmessage('Error: All channels must have the same number of samples and sample rate');
    exit;
   end;
   nt := length(lV.Events);
   if (nt < 1) then begin
      showmessage('Unable to generate average: no event file open.');
      exit;
   end;
   nsigchan := NumSignalChannels(lEEG);
   if nsigchan < 1 then begin
    showmessage('No signal channels');
    exit;
   end;
//crap
   lavesamples := round((lPrefs.AveDuration)/1000 * lEEG.Channels[0].SampleRate);    //inputs are msec, sample rate in Hz
   lBaselineSamples := 0;
   if (lPrefs.AveBaseline) and (lPrefs.AveBaselineDuration > 0) then
      lbaselinesamples := round((lPrefs.AveBaselineDuration)/1000 * lEEG.Channels[0].SampleRate);    //inputs are msec, sample rate in Hz
   lonsetshiftsamples  := round(lPrefs.AveStart/1000 * lEEG.Channels[0].SampleRate);
   if lavesamples < 1 then begin
    showmessage('You need to specify a averaging duration that spans at least one sample.');
    exit;
   end;
   //count and sort conditions - these are labels 'Cond1', 'Cond3', 'Cond1'...
   lCondStr := TStringList.Create;
   for t := 0 to nt-1 do
    lCondStr.add(lV.Events[t].Desc);
   RemoveDuplicates(lCondStr);
   if lCondStr.count < 1 then
    exit; //should be impossible
   //set condition of each trial as sorted integer...
   setlength(lCond,nt);
   for t := 0 to nt-1 do
    lCond[t] := lCondStr.IndexOf(lV.Events[t].Desc)+1;
   nCond :=  lCondStr.count;

   //prep output
   setlength(lonset,nt);
   for t := 0 to nt-1 do
    lonset[t] := lV.Events[t].OnsetSamp +lonsetshiftsamples;
   CompileStats (lEEG, lonset, lcond, lCondStr, lavesamples, lavesamples,lBaselineSamples,lonsetshiftsamples, lFilename,lV.VMRKfile, lPrefs);

   navechan := nsigchan * nCond;
   //setlength(lAveEEG.Channels,navechan);
   //ClearEEGHdr (lAveEEG);
   CreateEEG(lAveEEG, navechan,lavesamples, lEEG.Channels[0].SampleRate);
   //setlength(lAveEEG.Samples,navechan,lavesamples);
   setlength(averages,navechan);
   for c := 0 to navechan-1 do begin
    averages[c] := 0;
    for t := 0 to lavesamples-1 do
      lAveEEG.Samples[c][t] := 0;
   end;

   c := 0;
   for all := 0 to NumChannels(lEEG) do begin
    if (lEEG.Channels[all].SignalLead) and (c < navechan) then begin
      for cond := 1 to nCond do begin
         lAveEEG.Channels[c].info :=  lCondStr[cond-1]+'_'+lEEG.Channels[all].info;
         lAveEEG.Channels[c].unittype :=  lEEG.Channels[all].unittype;
         lAveEEG.Channels[c].SampleRate :=lEEG.Channels[all].SampleRate;
         lAveEEG.Channels[c].SignalLead := true;
          for t :=  0 to nt-1 do
             if  lCond[t]=cond then
                Add2Ave(lEEG.samples[all],lAveEEG.samples[c], lonset[t], lavesamples,lbaselinesamples,lonsetshiftsamples, averages[c],lPrefs.AveRectify);
         inc(c);
      end;
    end;//signallead
   end;
   for c := 0 to navechan-1 do begin
      if  averages[c] > 0 then begin
        for t := 0 to lavesamples-1 do
          lAveEEG.Samples[c][t] := lAveEEG.Samples[c][t] / averages[c];
      end;
      lAveEEG.Channels[c].info := lAveEEG.Channels[c].info+'_'+inttostr(averages[c]);
   end;
   CopyEEG(lAveEEG,lEEG);
   lCondStr.Free;
   //clean up
   //FreeandNil(lCond) ;
end;

end.
