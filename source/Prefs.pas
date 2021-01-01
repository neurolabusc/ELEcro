unit Prefs;
{$H+}

interface
uses
//Windows,
{$IFDEF Win32}
  Windows, //ShellAPI, Messages,
{$ELSE}
 // LResources,
 LCLIntf,
{$ENDIF}
IniFiles,SysUtils,graphics,Dialogs,Classes, filter_rbj;


type
  TFilter = record
       FiltHz,FiltQ,FiltDBGain:single;
       FiltType: integer;
       FiltBidirectional,FiltQIsBandWidth: boolean;
  end;

  TPrefs = record
         Filename, ConditionCollapseList: string;
         MouseDown: TPoint;
         QLowPassHz,QHiPassHz,QNotchHz: single;
         ButterHz,SoundStart,SoundChan,SoundDur,
         AveBaselineDuration,AveIgnore,AveThresh,AveTriggerChannel,AveStart,AveDuration,AvePulseTime, MouseInfoX,DisplayDist: integer;
         AveBaseline,QZeroMean, AveRectify,ShowVerticalAxis,HideDigital: boolean;
         TimeScale,Viewscale: double;
         Trace,Zero,Text,Background: TColor;
         F: TFilter;
  end;
procedure SetDefaultPrefs (var lPrefs: TPrefs);
procedure SetFiltDefaults (var lPrefs: TFilter);
function IniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;
var
   gP: TPrefs;

implementation

procedure SetFiltDefaults (var lPrefs: TFilter);
begin
  with lPrefs do begin
    FiltQ := 0.3;
    FiltDBGain:= 0;
    FiltHz := 20;
    FiltType := kHighPass;
    FiltQIsBandWidth := true;
    FiltBidirectional := false;
  end;
end;

procedure SetDefaultPrefs (var lPrefs: TPrefs);
begin
  SetFiltDefaults(lPrefs.F);
  with lPrefs do begin
    ConditionCollapseList := '1S,1S,1S,1S,2A,2A,2A,2A,2A,2A,3S,3S,3S,3S,4A,4A,4A,4A,4A,4A,5S,5S,5S,5S,6C,6C,6C,6C,6C,6C,7S,7S,7S,7S,8C,8C,8C,8C,8C,8C';
    ButterHz := 90;
    Trace := $aa0055;//$aa0055;//clBlue;
    Zero := clGray;
    Text := $660022;
    Background := $C8FFB4;//clBlack;
    DisplayDist := 0;
    ShowVerticalAxis := true;
    AveBaseline := false;
    AveBaselineDuration := 100;
    AveStart := 15;
    AveDuration := 50;
    AvePulseTime := 10;
    AveTriggerChannel := 4;
    AveThresh := 0;
    AveIgnore := 500;
    HideDigital := true;
    AveRectify := false;
    QZeroMean := true;
    SoundChan := 1;
    SoundDur := 1000;
    SoundStart := 1;
    //these do not need to be stored between sessions...
    ViewScale := 1;
    TimeScale := 0.5;
    MouseDown.X := 1;
    MouseDown.Y := 1;
    MouseInfoX := 1;
    QLowPassHz := 0;
    QHiPassHz := 0;
    QNotchHz := 0;
  end;//with lPrefs
end; //Proc SetDefaultPrefs

function TColorToHex( Color : TColor ) : string;
begin
  Result :=
    { red value }
    IntToHex( GetRValue( Color ), 2 ) +
    { green value }
    IntToHex( GetGValue( Color ), 2 ) +
    { blue value }
    IntToHex( GetBValue( Color ), 2 );
end;

function HexToTColor( sColor : string ) : TColor;
begin
  Result :=
    RGB(
      { get red value }
      StrToInt( '$'+Copy( sColor, 1, 2 ) ),
      { get green value }
      StrToInt( '$'+Copy( sColor, 3, 2 ) ),
      { get blue value }
      StrToInt( '$'+Copy( sColor, 5, 2 ) )
    );
end;

function StrToHex( sColor : string ) : TColor;
begin
  Result :=
    RGB(
      { get red value }
      StrToInt( '$'+Copy( sColor, 1, 2 ) ),
      { get green value }
      StrToInt( '$'+Copy( sColor, 3, 2 ) ),
      { get blue value }
      StrToInt( '$'+Copy( sColor, 5, 2 ) )
    );
end;

procedure IniColor(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: TColor);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('CLR',lIdent,{IntToHex(lValue,8)} TColorToHex(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('CLR',lIdent, '');
	if length(lStr) > 0 then
		lValue := HexToTColor(lStr);
end; //IniColor

procedure IniDouble(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: double);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('DBL',lIdent,FloattoStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('DBL',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToFloat(lStr);
end; //IniFloat

procedure IniSingle(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: single);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('DBL',lIdent,FloattoStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('DBL',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToFloat(lStr);
end; //IniFloat
(*procedure IniByte(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: byte);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('BYT',lIdent,InttoStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('BYT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToInt(lStr);
end; //IniFloat
              *)
function Bool2Char (lBool: boolean): char;
begin
     if lBool then
        result := '1'
     else
         result := '0';
end;

function Char2Bool (lChar: char): boolean;
begin
	if lChar = '1' then
		result := true
	else
		result := false;
end;

procedure IniInt(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: integer);
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
end; //IniInt

procedure IniBool(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: boolean);
//read or write a boolean value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('BOOL',lIdent,Bool2Char(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('BOOL',lIdent, '');
	if length(lStr) > 0 then
	   lValue := Char2Bool(lStr[1]);
end; //IniBool

procedure IniStr(lRead: boolean; lIniFile: TIniFile; lIdent: string; var lValue: string);
//read or write a string value to the initialization file
begin
  if not lRead then begin
    lIniFile.WriteString('STR',lIdent,lValue);
    exit;
  end;
	lValue := lIniFile.ReadString('STR',lIdent, '');
end; //IniStr

procedure IniChar(lRead: boolean; lIniFile: TIniFile; lIdent: string; var lValue: char);
//read or write a string value to the initialization file
var
  lS: string;
begin
  if not lRead then begin
    lIniFile.WriteString('STR',lIdent,lValue);
    exit;
  end;
	lS := lIniFile.ReadString('STR',lIdent, lValue);
  if length(lS)> 0 then
    lValue := lS[1];
end; //IniStr

function IniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;
//Read or write initialization variables to disk
var
  lIniFile: TIniFile;
begin
  result := false;
  if lRead then
     SetDefaultPrefs(lPrefs);
  if (lRead) and (not Fileexists(lFilename)) then
        exit;
  lIniFile := TIniFile.Create(lFilename);
  IniStr(lRead,lIniFile, 'Filename',lPrefs.Filename);
  IniStr(lRead,lIniFile, 'ConditionCollapseList',lPrefs.ConditionCollapseList);
  IniDouble(lRead,lIniFile, 'ViewScale',lPrefs.Viewscale);
  //IniDouble(lRead,lIniFile, 'TimeScale',lPrefs.Timescale);
  IniInt(lRead,lIniFile, 'DisplayDist',lPrefs.DisplayDist);
  IniInt(lRead,lIniFile, 'AveBaselineDuration',lPrefs.AveBaselineDuration);

  IniInt(lRead,lIniFile, 'AveStart',lPrefs.AveStart);
  IniInt(lRead,lIniFile, 'AvePost',lPrefs.AveDuration);
  IniInt(lRead,lIniFile, 'AvePulseTime',lPrefs.AvePulseTime);
  IniInt(lRead,lIniFile, 'AveTriggerChannel',lPrefs.AveTriggerChannel);
  IniInt(lRead,lIniFile, 'AveThresh',lPrefs.AveThresh);
  IniInt(lRead,lIniFile, 'AveIgnore',lPrefs.AveIgnore);

  IniInt(lRead,lIniFile, 'SoundChan',lPrefs.SoundChan);
  IniInt(lRead,lIniFile, 'SoundDur',lPrefs.SoundDur);
  IniInt(lRead,lIniFile, 'SoundStart',lPrefs.SoundStart);
  IniInt(lRead,lIniFile, 'ButterHz',lPrefs.ButterHz);


  IniBool(lRead,lIniFile, 'AveBaseline',lPrefs.AveBaseline);
  IniBool(lRead,lIniFile, 'HideDigital',lPrefs.HideDigital);
  IniBool(lRead,lIniFile, 'QZeroMean',lPrefs.QZeroMean);
  IniBool(lRead,lIniFile, 'AveRectify',lPrefs.AveRectify);
  IniBool(lRead,lIniFile, 'ShowVerticalAxis',lPrefs.ShowVerticalAxis);
  IniColor(lRead,lIniFile, 'Trace',lPrefs.Trace);
  IniColor(lRead,lIniFile, 'Zero',lPrefs.Zero);
  IniColor(lRead,lIniFile, 'Text',lPrefs.Text);
  IniColor(lRead,lIniFile, 'Background',lPrefs.Background);
  //finally - filter settings
  IniInt(lRead,lIniFile, 'FiltType',lPrefs.F.FiltType );
  IniBool(lRead,lIniFile, 'FiltQIsBandWidth',lPrefs.F.FiltQIsBandWidth );
  IniBool(lRead,lIniFile, 'FiltBidirectional',lPrefs.F.FiltBidirectional );
  IniSingle(lRead,lIniFile, 'FiltHz',lPrefs.F.FiltHz);
  IniSingle(lRead,lIniFile, 'FiltDBGain',lPrefs.F.FiltDBGain);
  IniSingle(lRead,lIniFile, 'FiltQ',lPrefs.F.FiltQ);


  IniSingle(lRead,lIniFile, 'QLowPassHz',lPrefs.QLowPassHz);
  IniSingle(lRead,lIniFile, 'QHiPassHz',lPrefs.QHiPassHz);
  IniSingle(lRead,lIniFile, 'QNotchHz',lPrefs.QNotchHz);
  lIniFile.Free;
end;

end.
