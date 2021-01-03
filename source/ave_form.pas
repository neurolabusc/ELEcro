unit ave_form;

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

  { TAverageForm }

  TAverageForm = class(TForm)
    AveDurationEdit: TSpinEdit;
    AveStartEdit: TSpinEdit;
    AveBaselineDurationEdit: TSpinEdit;
    BaselineCheck: TCheckBox;
    //RectifyCheck: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    OKbtn: TButton;
    CancelBtn: TButton;
    RectifyCheck: TCheckBox;
    GroupBox1: TGroupBox;
    //AveStartEdit: TSpinEdit;
    //AveDurationEdit: TSpinEdit;
    //BaselineCheck: TCheckBox;
    //AveBaselineDurationEdit: TSpinEdit;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKbtnClick(Sender: TObject);
    procedure BaselineCheckClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AverageForm: TAverageForm;

implementation
{$IFNDEF FPC} {$R *.dfm} {$ENDIF}
uses EEGMain;

procedure TAverageForm.FormShow(Sender: TObject);
begin
    AveStartEdit.Value := gP.AveStart;
    AveDurationEdit.Value := gP.AveDuration;
    RectifyCheck.Checked := gP.AveRectify;
    AveBaselineDurationEdit.Value := gP.AveBaselineDuration;
    BaselineCheck.Checked := gP.AveBaseline;
    BaselineCheckClick(nil);
end;

procedure TAverageForm.OKbtnClick(Sender: TObject);
begin
    gP.AveRectify :=  RectifyCheck.Checked;
    gP.AveStart := AveStartEdit.Value;
    gP.AveDuration := AveDurationEdit.Value;
    gP.AveBaselineDuration := AveBaselineDurationEdit.Value;
    gP.AveBaseline := BaselineCheck.Checked;

end;

procedure TAverageForm.BaselineCheckClick(Sender: TObject);
begin
    AveBaselineDurationEdit.enabled := BaselineCheck.Checked;
end;

initialization
{$IFDEF FPC}
  {$i ave_form.lrs}
  {$ENDIF}
end.
