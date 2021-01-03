unit EEGMain;
 {$IFDEF FPC} {$MODE Delphi}{$H+}  {$ENDIF}

interface

uses
{$IFDEF Darwin}
//CarbonOpenDoc,
{$ENDIF}
{$IFDEF Win32}
  Windows, ShellAPI, Messages,
{$ELSE}
  //LMessages,
LCLType,
{$ENDIF}
   {$IFDEF FPC}LResources, {$ENDIF}
   SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, StdCtrls, Prefs, format_all, Math, ClipBrd,
 eeg_type,filter_all,userdir,ave,tool_sound,filter_rbj,
  Spin, Buttons, ToolWin, ComCtrls,format_vmrk,deb,util_vmrk;

type

  { TMainForm }

  TMainForm = class(TForm)
    EventDesc: TEdit;
    EventTyp: TEdit;
  Filter1: TMenuItem;
    Lowpass1: TMenuItem;
    Highpass1: TMenuItem;
    Contaminatewithsignwave1: TMenuItem;
    Generatesinewaves1: TMenuItem;
    Average1: TMenuItem;
    Exportastabfile1: TMenuItem;
    Hidedigital1: TMenuItem;
    Events1: TMenuItem;
    Createeventfile1: TMenuItem;
    Collapseconditions1: TMenuItem;
    OpenDialogEvents: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    EventStatus: TPanel;
    SaveDialogEvents: TSaveDialog;
    SaveEvents: TMenuItem;
    Open2: TMenuItem;
    Merge1: TMenuItem;
    SaveDialogTab: TSaveDialog;
    Sound1: TMenuItem;
    //SaveDialogTab: TSaveDialog;
    Showscale1: TMenuItem;
    Savescreenshot1: TMenuItem;
    Save1: TMenuItem;
    EventFirst: TSpeedButton;
    EventPrev: TSpeedButton;
    EventNext: TSpeedButton;
    EventLast: TSpeedButton;
    DeleteEvent: TSpeedButton;
    EventOnset: TSpinEdit;
    EventDuration: TSpinEdit;
    TimeScrollBar: TScrollBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    EventBar: TToolBar;
    View1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    Copy1: TMenuItem;
    OpenDialog: TOpenDialog;
    ScrollBox: TScrollBox;
    TimeDisplayPanel: TImage;
    TimePanel: TImage;
    Verticalscale1: TMenuItem;
    Horizontalscale1: TMenuItem;
    Zoomin1: TMenuItem;
    Zoomout1: TMenuItem;
    ZoominH: TMenuItem;
    ZoomoutH: TMenuItem;
    Custom1: TMenuItem;
    TimeDisplayPanelBackBuffer: TImage;
    Channelspacing1: TMenuItem;
    Auto1: TMenuItem;
    Small1: TMenuItem;
    Medium1: TMenuItem;
    Large1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ColorDialog1: TColorDialog;
    Color1: TMenuItem;
    Background1: TMenuItem;
    ext1: TMenuItem;
    race1: TMenuItem;
    Zero1: TMenuItem;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    //EventBar: TToolBar;
    //EventFirst: TSpeedButton;
    //EventPrev: TSpeedButton;
    //EventNext: TSpeedButton;
    //DeleteEvent: TSpeedButton;
    //DeleteEvent: TSpeedButton;
    //EventTyp: TEdit;
    //EventOnset: TSpinEdit;
    //EventDuration: TSpinEdit;
    //EventDesc: TEdit;
    //Panel3: TPanel;
    //Panel4: TPanel;
    //EventStatus: TPanel;
    //SaveDialogEvents: TSaveDialog;
    Quickfilter1: TMenuItem;
    //OpenDialogEvents: TOpenDialog;
    procedure Average1Click(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure OpenEvents (lFilename: string);
    procedure TimeDisplayPanelMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TimeDisplayPanelResize(Sender: TObject);
    procedure xSetColor (var lC: TColor);
    procedure Copy2ForeGround (var lImage: TImage);
    procedure AutoScale;
    function DisplayDistX: integer;
    procedure UpdateScrollBar;
    procedure FileOpen;
    procedure Dummy (F1,F2,F3:double);
    procedure Open1Click(Sender: TObject);
    procedure ScrollBoxResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateTimeDisplay(DestCanvas: TCanvas=nil);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Exit1Click(Sender: TObject);
    procedure TimeScrollBarChange(Sender: TObject);
    procedure TimeDisplayPanelMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TimeDisplayPanelMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure Copy1Click(Sender: TObject);
    procedure ChannelSpacingClick(Sender: TObject);
    procedure CopyBackGround (var lImage: TImage);
    {$IFDEF Win32}procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;{$ENDIF}
    procedure Zoomin1Click(Sender: TObject);
    procedure Zoomout1Click(Sender: TObject);
    procedure ZoominHClick(Sender: TObject);
    procedure ZoomoutHClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure About1Click(Sender: TObject);
    procedure Custom1Click(Sender: TObject);
    procedure Zero1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Showscale1Click(Sender: TObject);
    procedure BWFilter(Sender: TObject);
    procedure SetVisibleChan;
    procedure Contaminatewithsignwave1Click(Sender: TObject);
    procedure Generatesinewaves1Click(Sender: TObject);
    procedure Exportastabfile1Click(Sender: TObject);
    procedure Sound1Click(Sender: TObject);
    procedure FilterERP(Sender: TObject);
    procedure Open2Click(Sender: TObject);
    procedure UpdateEvents;
    procedure EventFirstClick(Sender: TObject);
    procedure EventPrevClick(Sender: TObject);
    procedure EventNextClick(Sender: TObject);
    procedure EventLastClick(Sender: TObject);
    procedure DeleteEventClick(Sender: TObject);
    procedure SaveEventsClick(Sender: TObject);
    procedure Quickfilter1Click(Sender: TObject);
    procedure Createeventfile1Click(Sender: TObject);
    procedure Merge1Click(Sender: TObject);
    procedure Collapseconditions1Click(Sender: TObject);
    procedure Hidedigital1Click(Sender: TObject);


  private
    { Private declaration
    procedure EventPrevClick(Sender: TObject);s }
  public
      EEG : TEEG;
     // VMRK: TVMRK
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses ave_form,
  filter_form,
  about_form,
  trigger_form;

{$IFNDEF FPC}{$R *.dfm}{$ELSE}{$R *.lfm}{$ENDIF}
const
  VerticalAxisFrac = 0.4;
  DisplayLabelWidth  = 50;
 var  VMRK: TVMRK;
  {$IFDEF Win32}
procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);  //implement drag and drop
//NOTE: requires 'ShellAPI' in uses clause
//formcreate must include
//	DragAcceptFiles(Handle, True); //engage drag and dropend;
var
  CFileName: array[0..MAX_PATH] of Char;
begin
  try
    if DragQueryFile(Msg.Drop, 0, CFileName, MAX_PATH) > 0 then begin
      OpenDialog.Filename := (CFilename);
      FileOpen;
      Msg.Result := 0;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end; //WMDropFiles
{$ENDIF}


procedure SetDimension(lImage: TImage; lPGHt,lPGWid {,lBits}:integer);
var
   Bmp     : TBitmap;
begin
     if (lImage.Picture.Height = lPGHt) and (lImage.Picture.Width = lPGWid) then
      exit;
     Bmp        := TBitmap.Create;
     {$IFDEF FPC}
     Bmp.Height := lPGHt-2;
     Bmp.Width  := lPGwid-2;
     {$ELSE}
     Bmp.Height := lPGHt;
     Bmp.Width  := lPGwid;
     {$ENDIF}
     lImage.Picture.Assign(Bmp);
     lImage.width := round(Bmp.Width);
     lImage.height := round(Bmp.Height);
     Bmp.Free;
end;

function ReqDecimals (lV: double): integer;
//e.g. values >1 require no decimals, 0.999...0.1 require 1, etc...
var
  lF: double;
begin
  result := 0;
  if (lV = 0) or (lV > 1) then
       exit;
  lF := lV;
  repeat
    inc(result);
    lF := lF * 10;
  until (lF >= 1) or (result >= 10);
end;

procedure TMainForm.UpdateTimeDisplay(DestCanvas: TCanvas);
var
  vchan,dec,nvchan,nchan,maxsamp,DisplayDist,L, I, Start, DispCount, YOffset, XOffset, TimeOffset : Integer;
  SampleFreq, DI, DIInc, TimeStart : Double;
  lClip: boolean;
  TimeStr, Str : string;
  TPA: array of TPoint;
begin
  nchan := NumChannels(EEG);
  nvchan := NumVisibleChannels(EEG);

  maxsamp := MaxNumSamples (EEG);
  if (maxsamp < 1) then
    exit;
  lClip := true; //Windows Powerpoint has a problem with EMFs that have negative coordinates....
  DisplayDist := DisplayDistx;
  XOffset :=0;//only to prevent compiler warning
  SetDimension(TimeDisplayPanelBackBuffer,DisplayDist*nvchan+TimeDisplayPanel.Canvas.TextHeight('X'),ScrollBox.ClientWidth);
  SetDimension(TimeDisplayPanel,DisplayDist*nvchan+TimeDisplayPanel.Canvas.TextHeight('X'),ScrollBox.ClientWidth);
  {$IFDEF FPC}
  SetDimension(TimePanel,TimePanel.Height+2,TimePanel.Width);//+2 for OSX - border issues?
  {$ELSE}
  SetDimension(TimePanel,TimePanel.Height,TimePanel.Width);
  {$ENDIF}
  if DestCanvas=nil then begin
    DestCanvas:=TimeDisplayPanelBackBuffer.Canvas;
    TimeOffset:=0;
    lClip := false;
  end else
    TimeOffset:=TimeDisplayPanel.Height+10;
  with   DestCanvas do begin
      Font.color := gp.Text;
      Brush.Color := gp.Background;
      Brush.Style:=bsSolid;
      FillRect(ClipRect);
      Brush.Style:=bsClear;
      Start:=TimeScrollBar.Position;
      DispCount:=Min(Round((Width-DisplayLabelWidth)/gP.TimeScale),maxsamp-Start);
      //next - draw events
      if (length(VMRK.Events) > 0) and (Start  < (VMRK.Events[VMRK.CurrentEvent].OnsetSamp+VMRK.Events[VMRK.CurrentEvent].DurationSamp)) and ((Start+DispCount) > VMRK.Events[VMRK.CurrentEvent].OnsetSamp) then begin          //(VMRK.CurrentEvent < 0) or
          if gP.ShowVerticalAxis then
            XOffset:=2*DisplayLabelWidth
          else
            XOffset:=DisplayLabelWidth;

          Pen.Color := gp.Zero;
          L := max(round((VMRK.Events[VMRK.CurrentEvent].OnsetSamp-Start)*gP.TimeScale), 0);
          I := min(round((VMRK.Events[VMRK.CurrentEvent].OnsetSamp+VMRK.Events[VMRK.CurrentEvent].DurationSamp-Start)*gP.TimeScale), DispCount);
          if VMRK.Events[VMRK.CurrentEvent].Channel > 0 then begin
            YOffset:=(VMRK.Events[VMRK.CurrentEvent].Channel-1)*DisplayDist;
            Rectangle(XOffset+L,YOffset,XOffset+I,YOffset + DisplayDist);
          end else
            Rectangle(XOffset+L,2,XOffset+I,DisplayDist*nvchan-2);
          //caption := inttostr(XOffset+L)+'  '+inttostr(Xoffset+I)+'  '+inttostr(DispCount);
          Brush.Style:=bsClear;
      end;
      vchan := 0;
      for L:=0 to nchan-1 do begin
       if  EEG.Channels[L].visible then begin  //not a digital channel
        YOffset:=DisplayDist div 2+vchan*DisplayDist;
        inc(vchan);
        if not EEG.Channels[L].SignalLead then
          TextOut(1{DisplayLabelWidth-8-TextWidth(EEG.Channels[L].INfo)},YOffset-TextHeight(EEG.Channels[L].Info) div 2,'*'+EEG.Channels[L].Info)
        else
          TextOut(1,YOffset-TextHeight(EEG.Channels[L].Info) div 2,EEG.Channels[L].Info);
        if gP.ShowVerticalAxis then begin
          Pen.Color:=gp.Text; //clBlack;
          XOffset:=2*DisplayLabelWidth;
          I:=Round(DisplayDist*VerticalAxisFrac);
          MoveTo(XOffset,YOffset-I); LineTo(XOffset,YOffset+I);
          MoveTo(XOffset-2,YOffset-I); LineTo(XOffset+3,YOffset-I);
          MoveTo(XOffset-2,YOffset+I); LineTo(XOffset+3,YOffset+I);
          if (not EEG.Channels[L].SignalLead) or (EEG.Channels[L].DisplayScale = 0) then
             Str:=''
          else
              Str:=FormatFloat('0.00',-
              VerticalAxisFrac*DisplayDist/EEG.Channels[L].DisplayScale)+'uV';
          TextOut(XOffset-7-TextWidth(Str),YOffset+I-3*TextHeight(Str) div 4,Str);
          if (not EEG.Channels[L].SignalLead) or (EEG.Channels[L].DisplayScale = 0) then
            Str:=''
          else
            Str:=FormatFloat('0.00',VerticalAxisFrac*DisplayDist/EEG.Channels[L].DisplayScale)+'uV';
          TextOut(XOffset-7-TextWidth(Str),YOffset-I-TextHeight(Str) div 4,Str);
          Inc(XOffset);
        end else
          XOffset:=DisplayLabelWidth;
        Pen.Color:= gp.Zero;//;
        MoveTo(XOffset,YOffset);
        LineTo(Width,YOffset);
        Pen.Color:=gp.Trace;//clBlue;
        SetLength( TPA, DispCount );
        for i := 0 to DispCount-1 do begin
            with TPA[i] do begin
              X := XOffset+Round(I*gP.TimeScale);
              //Y := YOffset-random(55);
              Y := YOffset-Round(EEG.Samples[L,Start+I]*EEG.Channels[L].DisplayScale);
              if (lClip) and (Y < 0) then
                Y := 0;
            end;
        end;
        Polyline( TPA );
       end;
        //slower method: -->
        //MoveTo(XOffset,YOffset-Round(Sample[Start]*DisplayScale));
        //for I:=1 to DispCount-1 do LineTo(XOffset+Round(I*TimeScale),YOffset-Round(Sample[Start+I]*DisplayScale));
      end;
      SampleFreq:=EEG.Channels[0].SampleRate;

    end;



    if TimeOffset=0 then begin
      DestCanvas:=TimePanel.Canvas;
      DestCanvas.Font.Color := gP.Text;
      DestCanvas.Brush.Color:=gP.Background; //clBtnFace;
      DestCanvas.FillRect(DestCanvas.ClipRect);
    end;
    //next - time codes
    if SampleFreq>0 then with DestCanvas do begin
      Pen.Color:=clBlack;
      if gP.TimeScale>4.1 then DIInc:=SampleFreq/100
      else if gP.TimeScale>2.1 then DIInc:=SampleFreq/50
      else if gP.TimeScale>1.1 then DIInc:=SampleFreq/20
      else if gP.TimeScale>0.6 then DIInc:=SampleFreq/10
      else if gP.TimeScale>0.26 then DIInc:=SampleFreq/4
      else DIInc:=SampleFreq/2;
      Dec := ReqDecimals(DIInc/SampleFreq);
      //caption := floattostr(DIInc/SampleFreq);
      TimeStart:=Ceil(Start/DIInc)*DIInc;
      DI:=TimeStart-Start;
      while DI<=DispCount do begin
        I:=XOffset+Round(DI*gP.TimeScale);
        if TimeOffset=0 then
        begin
          MoveTo(I,16); LineTo(I,25);
        end
        else
        begin
          MoveTo(I,TimeOffset); LineTo(I,TimeOffset-10);     //OSX
        end;
        TimeStr := FloatToStrF((Start+DI)/SampleFreq, ffFixed,7,Dec);
        //x TimeStr:=FormatFloat('0.000',(Start+DI)/SampleFreq)+' s';
        TextOut(I-TextWidth(TimeStr) div 2,TimeOffset+1,TimeStr); //z
        DI:=DI+DIInc;
      end;
  end
  else if Assigned(TimePanel.Canvas) then with TimePanel.Canvas do
  begin
    Brush.Color:=clBtnFace;
    FillRect(ClipRect);
  end;
  Copy2ForeGround(TimeDisplayPanelBackBuffer);
  TimeDisplayPanel.Invalidate;
  TimePanel.Invalidate;
end;

function TMainForm.DisplayDistX: integer;
begin
   result := gP.DisplayDist;
   if result > 1 then
    exit;
    result := NumVisibleChannels(EEG);
    ScrollBox.Refresh;
    if (result < 1) or (ScrollBox.height <= result) then
      result := 64
    else
        result :=((ScrollBox.height-4- (TimeDisplayPanel.Canvas.TextHeight('X'))) div result);
    //MainForm.caption :=inttostr(random(888))+'  '+inttostr(ScrollBox.height)+'  '+inttostr(result)+'  '+ inttostr(result*NumChannels(EEG)+TimeDisplayPanel.Canvas.TextHeight('X'));
end;

procedure TMainForm.SetVisibleChan;
var
  nChan,L:integer;
begin
  nchan := NumChannels(EEG);
  if nChan < 1 then
    exit;
  if gP.HideDigital then
    for L:=0 to nchan-1 do
      EEG.Channels[L].visible :=  EEG.Channels[L].SignalLead
  else
    for L:=0 to nchan-1 do
      EEG.Channels[L].visible :=  true;
end;

procedure TMainForm.AutoScale;
var
  I : Integer;
  A : Single;
begin
  if MaxNumSamples(EEG) < 1 then
    exit;
  A := AbsoluteMaxInterval(EEG);
  if A=0 then
    exit;
  SetVisibleChan;
  if gP.ViewScale < 0 then
      gP.ViewScale := A/abs(gP.ViewScale)*2*VerticalAxisFrac;
  A:=gP.ViewScale*DisplayDistX/2/A;
  for I:=0 to NumChannels(EEG)-1 do begin
      if  EEG.Channels[I].SignalLead then
         EEG.Channels[I].DisplayScale:=A
      else
        AutoScaleEEG(EEG,I,DisplayDistX/2);
  end;
end;


procedure TMainForm.FileOpen;
var
  VMRKname,Ext: string;
begin
  VMRKname := '';
  Ext:=UpperCase(ExtractFileExt(OpenDialog.FileName));
  if Ext = '.VMRK' then begin
     VMRKname := OpenDialog.FileName;
     OpenDialog.FileName := VHDR4VMRK (OpenDialog.FileName);
  end;
  //showmessage( VMRKname+' -> '+OpenDialog.FileName);
  if (Ext = '.EEG') or (Ext='.VMRK') then begin
    OpenDialog.FileName := changefileext(OpenDialog.FileName,'.vhdr');
  end;
  if not Fileexists (OpenDialog.FileName) then begin
      showmessage('Unable to find '+OpenDialog.FileName);
      exit;
  end;
  SetLength(VMRK.Events,0);
  gP.Viewscale := 1;
  try
    LoadEEG(OpenDialog.Filename,EEG);
    AutoScale;
    UpdateScrollBar;
  finally
      Screen.Cursor:=crDefault;
  end;
  if MaxNumSamples(EEG) < 1 then
    exit;
  caption := OpenDialog.Filename + ' time='+FormatDateTime('yyyymmdd_hhnnss',EEG.Time)+'  samp/sec='+inttostr(round(EEG.Channels[0].SampleRate))+'  samp='+inttostr(round(MaxNumSamples(EEG)));
  if VMRKname <> '' then
    OpenDialogEvents.FileName := VMRKname
  else
    OpenDialogEvents.FileName := changefileext(OpenDialog.Filename,'.vmrk');
  if fileexists(OpenDialogEvents.FileName) then
    OpenEvents(OpenDialogEvents.FileName)
  else
    UpdateEvents;//hide events toolbar if it was visible
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if (Sender=Self) or OpenDialog.Execute then
    FileOpen;
end;

procedure TMainForm.UpdateScrollBar;
var
  Samp,lMax: integer;
begin
  Samp := MaxNumSamples(EEG);
  if Samp < 1 then
    exit;
  TimeScrollBar.PageSize:=1; //Round((TimeDisplayPanel.Width-DisplayLabelWidth)/TimeScale);
  if gP.ShowVerticalAxis then
      lMax:=Max(0,Samp-Round((TimeDisplayPanel.Width-2*DisplayLabelWidth)/gP.TimeScale))
  else
      lMax:=Max(0,Samp-Round((TimeDisplayPanel.Width-DisplayLabelWidth)/gP.TimeScale));
  //fx(lMax,TimeScrollBar.position);
  if lMax < 1 then
    lMax := 1;
  TimeScrollBar.Max := lMax;
(*  if gP.ShowVerticalAxis then
      TimeScrollBar.Max:=Max(0,Samp-Round((TimeDisplayPanel.Width-2*DisplayLabelWidth)/gP.TimeScale))
  else
      TimeScrollBar.Max:=Max(0,Samp-Round((TimeDisplayPanel.Width-DisplayLabelWidth)/gP.TimeScale)); *)
  UpdateTimeDisplay;
end;


procedure TMainForm.ScrollBoxResize(Sender: TObject);
begin
 UpdateScrollBar;
 //XL UpdateTimeDisplay;
end;

   function AppDir: string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/myapp.app/ for /folder/myapp.app/app
begin
 result := extractfilepath(paramstr(0));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
DecimalSeparator := '.';
writeln('a>>>>');
 {$IFDEF Win32}DragAcceptFiles(MainForm.Handle, True);
 {$ELSE}
 Sound1.visible := false;
 {$ENDIF}
{$IFDEF Darwin}Exit1.visible := false;
        //InitOpenDocHandler;//allows files to be associated...
        Open1.ShortCut := ShortCut(Word('O'), [ssMeta]);
        Save1.ShortCut := ShortCut(Word('S'), [ssMeta]);
        Copy1.ShortCut := ShortCut(Word('C'), [ssMeta]);
        Zoomin1.ShortCut := ShortCut(Word('V'), [ssMeta]);
        Zoomout1.ShortCut := ShortCut(Word('V'), [ssCtrl,ssMeta]);
        ZoominH.ShortCut := ShortCut(Word('H'), [ssMeta]);
        ZoomoutH.ShortCut := ShortCut(Word('H'), [ssCtrl,ssMeta]);
{$ENDIF}
  Caption:=Application.Title;
  SetDefaultPrefs (gP);
  IniFile(true, IniName, gP);
  writeln('>>>>');
  ScrollBox.DoubleBuffered:=true;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 IniFile(false, IniName, gP);
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.TimeScrollBarChange(Sender: TObject);
begin
  //UpdateTimeDisplay;
  //TimeDisplayPanel.Update;
  //TimePanel.Update;
  {$IFDEF XL}  UpdateScrollBar;  {$ENDIF}
  UpdateTimeDisplay;

end;

procedure TMainForm.CopyBackGround (var lImage: TImage);
var
  BMP: TBitmap;
begin
     Bmp        := TBitmap.Create;
     Bmp.Height := TimeDisplayPanelBackBuffer.Height;
     Bmp.Width  := TimeDisplayPanelBackBuffer.Width;
     lImage.Picture.Assign(TimeDisplayPanelBackBuffer.Picture);
     lImage.width := round(Bmp.Width);
     lImage.height := round(Bmp.Height);
     Bmp.Free;
end;

procedure TMainForm.Copy2ForeGround (var lImage: TImage);

begin
     TimeDisplayPanel.Picture.Assign(lImage.Picture);
     TimeDisplayPanel.width := round(lImage.Picture.Width);
     TimeDisplayPanel.height := round(lImage.Picture.Height);
end;

procedure TMainForm.TimeDisplayPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button=mbRight then begin
      gP.MouseDown.X:=X;
      gP.MouseDown.Y:=Y+ScrollBox.VertScrollBar.Position;
   end;
end;

var
   gRefresh: boolean = false;

procedure TMainForm.TimeDisplayPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  vchan,Samp,NY,I, L, YOffset,DisplayDist : Integer;
  Info : string;
  s: single;
  lImage : TImage;
begin
  Samp := MaxNumSamples(EEG);
  if Samp < 1 then
     exit;
     if gRefresh then exit;
    // gRefresh := true;
  DisplayDist := DisplayDistX;
  lImage := TImage.Create(self);
  lImage.Visible := false;
  CopyBackGround(lImage);
  if ssRight in Shift then begin
    TimeScrollBar.Position:=TimeScrollBar.Position+Round((gP.MouseDown.X-X)/gP.TimeScale);
    gP.MouseDown.X:=X;
  end;
  if (gP.MouseInfoX=X) {and gP.MouseInfoVisible} then Exit;
  (*if true{ gP.MouseInfoVisible} then begin
    inc(kte);
    TimeDisplayPanel.Repaint;
    TimePanel.Repaint;
  end;*)
    TimeDisplayPanel.Repaint;
    TimePanel.Repaint;
  if (X>=DisplayLabelWidth*2) then begin
    if gP.TimeScale = 0 then
      gP.TimeScale := 1;
    lImage.Canvas.Brush.Style:=bsClear;
    //lImage.Canvas.Brush.Style:=bsSolid;//asus

    lImage.Canvas.Font.Color := gp.Text;
    gP.MouseInfoX:=X;
    if gP.ShowVerticalAxis then
      I:=Round((X-2*DisplayLabelWidth)/gP.TimeScale+TimeScrollBar.Position)
    else
      I:=Round((X-DisplayLabelWidth)/gP.TimeScale+TimeScrollBar.Position);
      if (I< Samp) and (I > 0) then begin
      with lImage.Canvas do begin
        vchan := 0;
        for L:=0 to NumChannels(EEG)-1 do begin
         if  EEG.Channels[L].visible then begin
          s := EEG.Samples[L][I];
          if s = 0 then
             Info := '0'
          else if Abs(s)>=0.1 then
            Info:=FormatFloat('0.00',s)
          else
            Info:=FormatFloat('0.00e-0',s);
          YOffset:=DisplayDist div 2+vchan*DisplayDist;
          TextOut(2,YOffset+TextHeight('A'),Info);
          inc(vchan);
         end; //channel visible
        end;//for each channel
        Pen.Color:=gP.Text;
        MoveTo(X,0);
        LineTo(X,TimeDisplayPanel.Height);
      end;
      if EEG.Channels[0].SampleRate>0 then begin
        with TimePanel.Canvas do begin
          Brush.Color:=gp.Background; //.clBtnFace;
          Font.Color := gp.Text;
          Brush.Style:=bsSolid;
          Info:=FormatFloat('0.000',I/EEG.Channels[0].SampleRate)+' s';
          {$IFDEF  Unix} fillrect(2,3,TextWidth(Info),TextHeight('X')+3);{$ENDIF}
          TextOut(2,3,Info);   //problem on OSX
        end;
      end;
    end;
  end;
  Copy2ForeGround(lImage);
  lImage.Free;
  if ssRight in Shift then
  begin
    if ScrollBox.VertScrollBar.Visible then begin
      NY :=  gP.MouseDown.Y-Y;
      if NY < 0 then
        NY := 0
      else if NY > ScrollBox.VertScrollBar.Range then
        NY := ScrollBox.VertScrollBar.Range;
      if ScrollBox.VertScrollBar.Position <> NY then
      ScrollBox.VertScrollBar.Position := NY;
    end;
  end;
  gRefresh := false;
end;

procedure TMainForm.Copy1Click(Sender: TObject);
{$IFDEF FPC}
 begin
   if not SaveDialog1.Execute then exit;
   TimeDisplayPanel.Picture.Bitmap.SaveToFile(SaveDialog1.Filename);
 end;
{$ELSE}
var
  WMF : TMetafile;
  WMFCanvas : TMetafileCanvas;
begin
  UpdateTimeDisplay;
  TimeDisplayPanel.Update;
  TimePanel.Update;
  TimeDisplayPanel.Height:=DisplayDistX*NumChannels(EEG);
  WMF:=TMetafile.Create;
  try
    WMF.Width:=TimeDisplayPanelBackBuffer.Width;
    WMF.Height:=TimeDisplayPanelBackBuffer.Height+TimePanel.Height;
    WMFCanvas:=TMetafileCanvas.Create(WMF,0);
    try
      WMFCanvas.Font.Name:='Arial';
      UpdateTimeDisplay(WMFCanvas);
    finally
      WMFCanvas.Free;
    end;
    if (Sender as TMenuItem).tag = 1 then begin
      if SaveDialog1.execute then
        WMF.SaveToFile(savedialog1.FileName);
    end else
      Clipboard.Assign(WMF);
  finally
    WMF.Free;
  end;
end;
{$ENDIF}

procedure TMainForm.ChannelSpacingClick(Sender: TObject);
begin
  gP.DisplayDist:=TMenuItem(Sender).Tag;
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.Zoomin1Click(Sender: TObject);
begin
    gP.ViewScale:=gP.Viewscale * 2;
    AutoScale;
    UpdateTimeDisplay;
end;

procedure TMainForm.Zoomout1Click(Sender: TObject);
begin
    gP.ViewScale:=gP.Viewscale / 2;
    AutoScale;
    UpdateTimeDisplay;
end;

procedure TMainForm.ZoominHClick(Sender: TObject);
begin
  gP.TimeScale:=gP.TimeScale*2;
  if gP.TimeScale>256 then gP.TimeScale:=256;
  {$IFDEF XL} UpdateScrollBar; {$ENDIF}
      UpdateTimeDisplay;
end;

procedure TMainForm.ZoomoutHClick(Sender: TObject);
begin
  gP.TimeScale:=gP.TimeScale/2;
  if gP.TimeScale<1/256 then gP.TimeScale:=1/256;
  UpdateScrollBar;
end;

procedure TMainForm.Dummy(F1,F2,F3: double);
begin
  gP.Viewscale:=-100;
  LoadEEGDummy(EEG, F1,F2,F3);
  caption := floattostr(F1)+':'+floattostr(F2)+':'+floattostr(F3)+'Hz   '+inttostr(MaxNumSamples(EEG));
  AutoScale;
  {$IFDEF XL} UpdateScrollBar; {$ENDIF}
  UpdateTimeDisplay;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin

  case gP.DisplayDist of
    64: Small1.Checked := true;
    128: Medium1.Checked := true;
    256: Large1.Checked := true;
    else Auto1.checked := true;
  end;
  Showscale1.Checked := gP.ShowVerticalAxis;
  Hidedigital1.Checked := gP.HideDigital;
  //{$DEFINE DBUG}
  {$IFDEF DBUG}
  OpenDialog.FileName := '/Users/chrisrorden/Desktop/sampledata/20100806_122102.vhdr';
  FileOpen;
  {$ELSE}
  Dummy (13,60,131);
  {$ENDIF}
 (* //OpenDialog.FileName := 'c:\tdcs\lefthemitms.vhdr';
  //FileOpen;
 //LoadVMRK('c:\tdcs\lefthemitms.vmrk', VMRK);
 //VMRK.CurrentEvent := 0;
 *)
 //UpdateEvents;
  {$IFDEF FPC} Application.ShowButtonGlyphs := sbgNever; {$ENDIF}
end;

procedure TMainForm.Custom1Click(Sender: TObject);
var
 Str : string;
 A: double;
begin
  if MaxNumSamples(EEG) < 1 then begin
    showmessage('Please open data first');
    exit;
  end;
  A := AbsoluteMaxInterval(EEG);
      gP.ViewScale := 2*VerticalAxisFrac*A/gP.ViewScale ;
  Str:=FormatFloat('0.####',gP.ViewScale);
  if not InputQuery('Vertical scale factor','Enter desired range:',Str) then
    exit;
  try
    A := -StrToFloat(Str);    // Middle blanks are not supported
  except
      on Exception : EConvertError do begin
      ShowMessage(Exception.Message);
          A := gP.ViewScale;
      end ;
  end;
  gP.ViewScale:=A;
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.xSetColor (var lC: TColor);
begin
    ColorDialog1.Color := lC;
    ColorDialog1.CustomColors.clear;
    ColorDialog1.CustomColors.Add('ColorA=' + IntToHex(gP.background, 8));
    ColorDialog1.CustomColors.Add('ColorB=' + IntToHex(gP.Text, 8));
    ColorDialog1.CustomColors.Add('ColorC=' + IntToHex(gP.Trace, 8));
    ColorDialog1.CustomColors.Add('ColorD=' + IntToHex(gP.Zero, 8));
    if not ColorDialog1.execute then
      exit;
    lC := MainForm.ColorDialog1.Color;
end;

procedure TMainForm.Zero1Click(Sender: TObject);
begin
  case (Sender as TMenuItem).Tag of
    1: xSetColor(gP.Text);
    2: xSetColor(gP.Trace);
    3: xSetColor(gP.Zero);
    else xSetColor(gP.background);
  end;
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.Save1Click(Sender: TObject);
begin
  if MaxNumSamples(EEG) < 1 then begin
    Showmessage('You need to load data before you can save.');
    exit;
  end;
  if not SaveDialog2.Execute then
    exit;
  WriteEEG(SaveDialog2.FileName,EEG);
end;

procedure TMainForm.Showscale1Click(Sender: TObject);
begin
  gP.ShowVerticalAxis := showscale1.checked;
    AutoScale;
    UpdateTimeDisplay;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
begin
 if (vk_Down = Key) then
    Zoomout1Click(nil);
  if (vk_Up = Key) then
    Zoomin1Click(nil);
  if (vk_End = Key) then
    TimeScrollBar.Position := TimeScrollBar.Max;
  if (vk_End = Key) then
    TimeScrollBar.Position := TimeScrollBar.Max;
  if (vk_Home = Key) then
    TimeScrollBar.Position := 1;
  if (vk_Right = Key) or (vk_Left = Key) then begin
    i := TimeScrollBar.Max div 100;
    if i < 1 then
      i := 1;
    if (vk_Left = Key) then
      TimeScrollBar.Position := TimeScrollBar.Position-i
    else
        TimeScrollBar.Position := TimeScrollBar.Position+i;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  UpdateScrollBar;
  UpdateTimeDisplay;
end;

procedure TMainForm.ScrollBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  if WheelDelta < 0 then
    Zoomout1Click(nil)
  else
    Zoomin1Click(nil);
end;

procedure TMainForm.TimeDisplayPanelMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
    ScrollBoxMouseWheel(Sender,Shift,Wheeldelta,MousePos,Handled);
end;

procedure TMainForm.TimeDisplayPanelResize(Sender: TObject);
begin
  UpdateTimeDisplay;
end;

function GetReal (lComment: string; var lValue: double): boolean;
var
  Str: string;
begin
  result := false;
  Str:=FormatFloat('0.####',lValue);
  if not InputQuery('Input required',lComment,Str) then
    exit;
  try
    lValue := StrToFloat(Str);    // Middle blanks are not supported
  except
      on Exception : EConvertError do
        exit;
  end;
  result := true;
end;

function GetInt (lComment: string; var lValue: integer): boolean;
var
  Str: string;
begin
  result := false;
  Str:=FormatFloat('0',lValue);
  if not InputQuery('Input required',lComment,Str) then
    exit;
  try
    lValue := StrToInt(Str);    // Middle blanks are not supported
  except
      on Exception : EConvertError do
        exit;
  end;
  result := true;
end;

procedure TMainForm.Contaminatewithsignwave1Click(Sender: TObject);
const
  lHz: double = 60;
  lAmp: double = 100;
begin
  lHz := 60;
  lAmp := 400;
  if not GetReal('Enter Hz for contamination',lHz) then exit;
  if not GetReal('Enter Amplitude of contamination',lAmp) then exit;
  AddSineWave(EEG,lHz,lAmp);
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.BWFilter(Sender: TObject);
begin
  if not GetInt('Low pass filter (Hz)',gP.ButterHz) then exit;
  LowPass(EEG,gP.ButterHz);
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.Generatesinewaves1Click(Sender: TObject);
const
  F1 : double = 13;
  F2 : double = 60;
  F3 : double = 131;
begin
  if not GetReal('Enter 1st Hz for signal',F1) then exit;
  if not GetReal('Enter 2nd Hz for signal',F2) then exit;
  if not GetReal('Enter 3rd Hz for signal',F3) then exit;
  Dummy(F1,F2,F3);
end;

procedure TMainForm.Exportastabfile1Click(Sender: TObject);
begin
  if NumChannels(EEG) < 1 then begin
    showmessage('Please load dataset you would like to export.');
    exit;
  end;
  if TotalNumSamples(EEG) > (1024*8) then 
	  case MessageDlg('Text export is designed for averaged data, and is not recommended for large datasets. Continue?', mtConfirmation,
				[mbYes, mbCancel], 0) of	{ produce the message dialog box }
				mrCancel: exit;
	  end; //case
  if not SaveDialogTab.Execute then exit;
  WriteEEGasTab(SaveDialogTab.FileName,EEG);
end;


procedure TMainForm.Sound1Click(Sender: TObject);
var
  lc: integer;
begin
  inherited;
  if not (Sound1.Checked) then
    StopSoundX
  else begin
    lc := NumChannels(EEG);
    if lC < 1 then begin
      showmessage('Please first load polygraphic data.');
      exit;
    end;
    if not GetInt('Enter channel number [1..'+inttostr(lC)+']',gP.SoundChan) then exit;
    if (gP.SoundChan > lC) or (gP.SoundChan < 1) then begin
        gP.SoundChan := 1;
        showmessage('Sound channel is a value 1..'+inttostr(lc));
    end;
    if not GetInt('Enter duration (ms).',gP.SoundDur) then exit;
    if not GetInt('Enter start time (ms).',gP.SoundStart) then exit;
    CreateSound (EEG,gP.SoundChan, gP.SoundStart,gP.SoundDur);
  end;
end;


procedure TMainForm.FilterERP(Sender: TObject);
begin
  FilterForm.ShowModal;
  if FilterForm.ModalResult <> mrOK then
    exit;
  FilterRBJ (EEG, gP.F);
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.OpenEvents (lFilename: string);
begin
 LoadVMRK(lFilename, VMRK);
 VMRK.CurrentEvent := 0;
 UpdateEvents;
end;

procedure TMainForm.Open2Click(Sender: TObject);
begin
  if not OpenDialogEvents.Execute then
      exit;
 OpenEvents(OpenDialogEvents.FileName);
end;

procedure TMainForm.UpdateEvents;
const
  kPreEventSamples = 10;
var
  t,n: integer;
begin
  n := length(VMRK.Events);
  if n < 1 then begin
    EventBar.visible := false;
    exit;
  end;
  EventBar.visible := true;
  if (VMRK.CurrentEvent < 0) or (VMRK.CurrentEvent > (n-1)) then
    VMRK.CurrentEvent := 0;
  t :=  VMRK.CurrentEvent;
  EventTyp.Text := VMRK.Events[t].Typ;
  EventDesc.Text := VMRK.Events[t].Desc;
  //VMRK.Events[t].Desc := inttostr(t)+'desc';
  EventOnset.Value := VMRK.Events[t].OnsetSamp;
  EventDuration.Value := VMRK.Events[t].DurationSamp;
  //VMRK.Events[t].Channel := 0;
  EventStatus.Caption := inttostr(t+1) +'/'+inttostr(n);
  if (VMRK.Events[t].OnsetSamp > TimeScrollBar.Max)  then
    TimeScrollBar.Position :=TimeScrollBar.Max - kPreEventSamples
  else if VMRK.Events[t].OnsetSamp > kPreEventSamples then
    TimeScrollBar.Position :=VMRK.Events[t].OnsetSamp - kPreEventSamples
  else
    TimeScrollBar.Position := 0;
  {$IFDEF XL}  UpdateScrollBar;  {$ENDIF}
  UpdateTimeDisplay;
end;

procedure TMainForm.EventFirstClick(Sender: TObject);
begin
   VMRK.CurrentEvent := 0;
   UpdateEvents;
end;

procedure TMainForm.EventPrevClick(Sender: TObject);
begin
  if VMRK.CurrentEvent > 0 then
    VMRK.CurrentEvent := VMRK.CurrentEvent -1;
  UpdateEvents;
end;

procedure TMainForm.EventNextClick(Sender: TObject);
begin
  if VMRK.CurrentEvent < (length(VMRK.Events)-1) then
    VMRK.CurrentEvent := VMRK.CurrentEvent +1;
  UpdateEvents;
end;

procedure TMainForm.EventLastClick(Sender: TObject);
begin
    VMRK.CurrentEvent := length(VMRK.Events)-1;
  UpdateEvents;
end;

procedure TMainForm.DeleteEventClick(Sender: TObject);
var
  i,cur,n: integer;
begin
  n := length(VMRK.Events);
  cur := VMRK.CurrentEvent; //indexed from 0
  if (n < 1) or (cur < 0) or (cur >= n) then
    exit;
  if cur = (n-1) then  //last item
    VMRK.CurrentEvent := VMRK.CurrentEvent -1
  else //not last item
    for i := cur to (n-2) do
      VMRK.Events[i] := VMRK.Events[i+1];
  setlength(VMRK.Events,n-1);
  UpdateEvents;
end;

procedure TMainForm.SaveEventsClick(Sender: TObject);
begin
  if length(VMRK.Events) < 1 then begin
    showmessage('Unable to save events file: no events open.');
    exit;
  end;
  if not SaveDialogEvents.Execute then
      exit;
  WriteVMRK(SaveDialogEvents.FileName, VMRK);
end;

procedure TMainForm.Quickfilter1Click(Sender: TObject);
var
  lS: string;
  lF: TFilter;
begin
  lS := '';
  if (gP.QZeroMean)  then begin
    FilterZeroMean (EEG);
    lS := lS+'ZeroMean' ;
  end;
  if (gP.QHiPassHz <> 0)  then begin
    SetFiltDefaults(lF);
    lF.FiltHz := gP.QHiPassHz;
    lF.FiltType := kHighPass;
    FilterRBJ (EEG, lF);
    lS := lS+'HP='+floattostr(lF.FiltHz)+' ';
  end;
  if (gP.QLowPassHz <> 0)  then begin
    SetFiltDefaults(lF);
    lF.FiltHz := gP.QLowPassHz;
    lF.FiltType := kLowPass;
    FilterRBJ (EEG, lF);
    lS := lS+'LP='+floattostr(lF.FiltHz)+' ';
  end;
  if (gP.QNotchHz <> 0) then begin
    SetFiltDefaults(lF);
    lF.FiltHz := gP.QNotchHz;
    lF.FiltType := kNotch;
    FilterRBJ (EEG, lF);
    lS := lS+'Notch='+floattostr(lF.FiltHz)+' ';
  end;
  Caption := lS;
  AutoScale;
  UpdateTimeDisplay;
end;

procedure TMainForm.Average1Click(Sender: TObject);
begin
  if length(VMRK.Events) < 1 then begin
    showmessage('Unable to average events file: no events open.');
    exit;
  end;
  if NumChannels(EEG) < 1 then begin
      showmessage('Please first load polygraphic data.');
      exit;
  end;
  AverageForm.Showmodal;
  if AverageForm.ModalResult <> mrOK then
    exit;
  SaveDialogTab.Execute;
  //WriteEEGasTab(,EEG);
  Average (EEG,VMRK ,gP,SaveDialogTab.FileName);
  //SaveDialogTab.FileName := changefileext(SaveDialogTab.FileName,'trace.tab');
  if SaveDialogTab.FileName <> '' then
    WriteEEGasTab(SaveDialogTab.FileName,EEG);
  AutoScale;
  UpdateScrollBar;
end;

procedure TMainForm.FormDropFiles(Sender: TObject;
  const FileNames: array of string);
var
  fnm: string;
begin
 fnm := Filenames[0];
 if not fileexists(fnm) then exit;
 OpenDialog.FileName := fnm;
 FileOpen;
end;

procedure TMainForm.Createeventfile1Click(Sender: TObject);
var
  lV: TVMRK;
begin
    if NumChannels(EEG) < 1 then begin
      showmessage('Please first load polygraphic data.');
      exit;
    end;
    Trigger2EventsForm.Showmodal;
    if Trigger2EventsForm.ModalResult <> mrOK then
      exit;
    Trigger2Event (EEG,gP.AveTriggerChannel, gP.AvePulseTime,gP.AveThresh,gP.AveIgnore,lV);
    SaveDialogEvents.FileName := changefileext(EEG.DataFile,'.vmrk');
    if (length(lV.Events) < 1) or (not SaveDialogEvents.Execute) then
      exit;
    WriteVMRK(SaveDialogEvents.FileName, lV);
    LoadVMRK(SaveDialogEvents.FileName, VMRK);
    VMRK.CurrentEvent := 0;
    UpdateEvents;
end;

procedure TMainForm.Merge1Click(Sender: TObject);
label 667;
var
 lReconciledName,lGoodTiming,lGoodCond: string;
begin
 OpenDialogEvents.title := 'Select events file with accurate timing information';
 if not OpenDialogEvents.Execute then
      goto 667;
 lGoodTiming := OpenDialogEvents.FileName;
 OpenDialogEvents.title := 'Select events file with accurate condition labels';
 if not OpenDialogEvents.Execute then
      goto 667;
 lGoodCond := OpenDialogEvents.FileName;
 SaveDialogEvents.FileName := changefileext(lGoodCond,'r.vmrk');
 if not SaveDialogEvents.Execute then
      exit;
 lReconciledName := SaveDialogEvents.FileName;
 MergeVMRK(lGoodTiming,lGoodCond,lReconciledName,3);
 //LoadVMRK(lFilename, VMRK);
 667:
 OpenDialogEvents.title := 'Select an events file';
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutForm.showmodal;
end;

procedure TMainForm.Collapseconditions1Click(Sender: TObject);
var
  lInputname,lReconciledName,CollapsedNames: string;
begin
  CollapsedNames := gP.ConditionCollapseList;// 'a,a,b,b,b,b,a,a';
 inputquery('Enter new condition names','New names [e.g. Atdcs, Btms, Atdcs, Csham]',CollapsedNames);
 if CollapsedNames = '' then
  exit;
 gP.ConditionCollapseList := CollapsedNames;
 if not OpenDialogEvents.Execute then
      exit;
 lInputname := OpenDialogEvents.FileName;
 lReconciledName := changefileext(lInputname,'c.vmrk');
 SaveDialogEvents.FileName := lReconciledName;
 if not SaveDialogEvents.Execute then
      exit;
 lReconciledName := SaveDialogEvents.FileName;
 CollapseVMRK(lInputName, lReconciledName,CollapsedNames);
end;

procedure TMainForm.Hidedigital1Click(Sender: TObject);
//var
//  nChan,L:integer;
begin
  gP.HideDigital:=Hidedigital1.Checked;
  AutoScale;
  {$IFDEF XL} UpdateScrollBar; {$ENDIF}
      UpdateTimeDisplay;
end;

end.
