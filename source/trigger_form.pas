unit trigger_form;                                                         

interface

uses
  {$IFDEF Win32}
  Windows,  Messages,
{$ELSE}
  LMessages, LCLType,
{$ENDIF}
   {$IFDEF FPC}LResources, {$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin,prefs,eeg_type, ave;

type
  TTrigger2EventsForm = class(TForm)
    Label1: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    AvePulseTimeEdit: TSpinEdit;
    AveTriggerChannelEdit: TSpinEdit;
    AveThreshEdit: TSpinEdit;
    OKbtn: TButton;
    CancelBtn: TButton;
    Label2: TLabel;
    AveIgnoreEdit: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure OKbtnClick(Sender: TObject);
    procedure AveTriggerChannelEditChange(Sender: TObject);
    procedure AveThreshEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Trigger2EventsForm: TTrigger2EventsForm;

implementation


{$IFNDEF FPC}{$R *.dfm}{$ELSE}{$R *.lfm}{$ENDIF}
uses EEGMain;

procedure TTrigger2EventsForm.FormShow(Sender: TObject);
begin
    AveThreshEdit.Value := gP.AveThresh;
    AvePulseTImeEdit.Value := gP.AvePulseTime;
    if (gP.AveTriggerChannel >= NumChannels(MainForm.EEG)) then
      gP.AveTriggerChannel := NumChannels(MainForm.EEG);
    AveTriggerChannelEdit.value := gP.AveTriggerChannel+1; //+1 as indexed from 0
    AveIgnoreEdit.value := gP.AveIgnore;
    AveTriggerChannelEdit.MaxValue := NumChannels(MainForm.EEG);
    AveTriggerChannelEditChange(nil);
    AveThreshEditChange(nil);

end;

procedure TTrigger2EventsForm.OKbtnClick(Sender: TObject);
begin
    gP.AveThresh := AveThreshEdit.Value;
    gP.AvePulseTime := AvePulseTImeEdit.Value;
    gP.AveTriggerChannel := AveTriggerChannelEdit.value-1;//-1 as indexed from o
    gP.AveIgnore := AveIgnoreEdit.Value;

end;

procedure TTrigger2EventsForm.AveTriggerChannelEditChange(Sender: TObject);
begin
  Label1.Caption := 'Channel ['+ChannelName(MainForm.EEG,AveTriggerChannelEdit.value-1)+']';
end;

procedure TTrigger2EventsForm.AveThreshEditChange(Sender: TObject);
begin
  Label6.caption :='Threshold '+floattostr(IntToThresh(AveThreshEdit.value));
end;

end.
