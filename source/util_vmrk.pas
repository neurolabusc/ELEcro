unit util_vmrk;
{$IFDEF FPC} {$MODE Delphi}{$H+}  {$ENDIF}

interface

uses format_vmrk, dialogs, sysutils, classes, ave;

function MergeVMRK(var lGoodTiming,lGoodCond, lReconciledName: string; PadCondDigits: integer): boolean;

function CollapseVMRK(var lInputName, lReconciledName,CollapsedNames: string): boolean;

implementation

function IsDigit (lCh: Char): boolean;
begin
  result := (lCh in ['0'..'9']);

end;

function IsAlphanumeric (lCh: Char): boolean;
begin
  result := (lCh in ['0'..'9','a'..'z','A'..'Z']);

end;

procedure PadStr (var lStr: string; lPadLen: integer);
var
  lPad,lOrigLen,lStart,lEnd,i : integer;
  lOutStr: string;
begin
 if lPadLen < 1 then
  exit;
 lOrigLen := length(lStr);
 if lOrigLen < 1 then
  exit;
 lStart := 1;
 while (lStart < lOrigLen) and (not IsDigit(lStr[lStart])) do
  inc(lStart);
 if not IsDigit(lStr[lStart]) then
  exit;
 lEnd := lStart;
 while (lEnd < lOrigLen) and (IsDigit(lStr[lEnd+1])) do
  inc(lEnd);
 lPad := lPadLen- (lEnd-lStart+1);
 if lPad < 1 then
  exit;
 lOutStr := '';
 if lStart > 1 then
  for i := 1 to (lStart-1) do
    lOutStr := lOutStr + lStr[i];
 for i := 1 to (lPad) do
  lOutStr := lOutStr + '0';
  for i := lStart to lOrigLen do
    lOutStr := lOutStr + lStr[i];
  lStr := lOutStr;
end;

function MergeVMRK(var lGoodTiming,lGoodCond, lReconciledName: string; PadCondDigits: integer): boolean;
var
  vGoodTiming, vGoodCond: TVMRK;
  i,nGoodTiming,nGoodCond: integer;
begin
  result := false;
  if not LoadVMRK(lGoodTiming, vGoodTiming) then begin
    Showmessage('No events found in file '+lGoodTiming);
    exit;
  end;
  if not LoadVMRK(lGoodCond, vGoodCond) then begin
    Showmessage('No events found in file '+lGoodCond);
    exit;
  end;
  nGoodTiming :=length(vGoodTiming.Events);
  nGoodCond :=length(vGoodCond.Events);
  if (nGoodTiming < 1) then begin
    Showmessage('No events found in file '+lGoodTiming);
    exit;
  end;
  if (nGoodCond < 1) then begin
    Showmessage('No events found in file '+lGoodCond);
    exit;
  end;
  if (nGoodTiming <> nGoodCond) then begin
    Showmessage('Unable to reconcile files: counted  '+ inttostr(nGoodTiming)+ ' events with good timing, and '+inttostr(nGoodCond)+' events with good conditions');
    exit;
  end;
  for i := 0 to nGoodCond - 1 do
    vGoodCond.Events[i].OnsetSamp := vGoodTiming.Events[i].OnsetSamp;
  if PadCondDigits > 0 then
    for i := 0 to nGoodCond - 1 do
      PadStr(vGoodCond.Events[i].Desc,PadCondDigits );

  result := WriteVMRK(lReconciledName, vGoodCond);
end;

procedure StrToStrList(lStr: string; var lList: TStringList);
var
  i, len: integer;
  lS: string;
begin
    lList.Clear;
    len := length(lStr);
    if len < 1 then
      exit;
    lS := '';
    for i := 1 to len do begin
      //extract each item
      if IsAlphanumeric(lStr[i]) then
        lS := lS + lStr[i]
      else if lS <> '' then begin
        lList.Add(lS);
        lS := '';
      end;
    end;
    if lS <> '' then 
        lList.Add(lS);
end;

function CollapseVMRK(var lInputName, lReconciledName,CollapsedNames: string): boolean;
var
  lV: TVMRK;
  c,nc, t,nt: integer;
  lS: string;
  lCondStr,lCollapsedList: TStringList;
begin
  result := false;
  if not LoadVMRK(lInputName, lV) then begin
    Showmessage('No events found in file '+lInputName);
    exit;
  end;
  nt :=length(lV.Events);
  if (nt < 1) then begin
    Showmessage('No events found in file '+lInputName);
    exit;
  end;
  lCollapsedList := TStringList.Create;
  StrToStrList(CollapsedNames, lCollapsedList);
  lCondStr := TStringList.Create;
  for t := 0 to nt-1 do
    lCondStr.add(lV.Events[t].Desc);
  RemoveDuplicates(lCondStr); //returns aplhabetically sorted list... 1..nCondOrig
  nc := lCondStr.Count;
  if lCollapsedList.Count < nc then begin
    Showmessage('There are '+ inttostr(lCondStr.Count)+' conditions in the source file, but only '+inttostr(lCollapsedList.Count)+' conditions in the collapsed list.');
    exit;
  end;
  for t := 0 to nt-1 do begin
    lS := lV.Events[t].Desc;
    for c := 0 to nc-1 do
      if lS = lCondStr[c] then
        lS := lCollapsedList[c];
    lV.Events[t].Desc := lS;
  end;
  result := WriteVMRK(lReconciledName, lV);
  for c := 0 to nc-1 do
     lCollapsedList[c] := lCondStr[c]+' -> '+lCollapsedList[c];
  lCollapsedList.SaveToFile(changefileext(lReconciledName,'.txt'));
end;


end.
 
