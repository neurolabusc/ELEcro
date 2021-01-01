unit filter_form;

interface

uses
    {$IFDEF Win32}
  Windows,  Messages,
{$ELSE}
  LMessages, LCLType,
{$ENDIF}
   {$IFDEF FPC}LResources, {$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Prefs,filter_rbj;

type

  { TFilterForm }

  TFilterForm = class(TForm)
    GainLabel: TLabel;
    OKbtn: TButton;
    CancelBtn: TButton;
    DefBtn: TButton;
    FiltQIsBandWidthCheck: TCheckBox;
    FiltTypeDrop: TComboBox;
    FiltHzEdit: TEdit;
    FiltDBGainEdit: TEdit;
    FiltQEdit: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    FiltBidirectionalCheck: TCheckBox;
    procedure OKbtnClick(Sender: TObject);
    procedure DefBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure WritePrefs;
    procedure FiltTypeDropChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FilterForm: TFilterForm;

implementation
{$IFNDEF FPC}{$R *.dfm}{$ELSE}{$R *.lfm}{$ENDIF}

procedure TFilterForm.OKbtnClick(Sender: TObject);
begin
  with gP.F do begin
    FiltType := FiltTypeDrop.ItemIndex;
    FiltHz := StrToFloat(FiltHzEdit.Text);
    FiltDBGain:= StrToFloat(FiltDBGainEdit.Text);
    FiltQ := StrToFloat(FiltQEdit.Text);
    FiltQIsBandWidth := FiltQIsBandWidthCheck.checked;
    FiltBidirectional := FiltBidirectionalCheck.checked;
  end;
end;

procedure WriteReal(E: TEdit; lValue: single);
begin
  E.Text := FormatFloat('0.####',lValue);
end;

procedure TFilterForm.WritePrefs;
begin
  with gP.F do begin
    FiltTypeDrop.ItemIndex := FiltType;
    WriteReal(FiltHzEdit,FiltHz);
    WriteReal(FiltDBGainEdit,FiltDBGain);
    WriteReal(FiltQEdit, FiltQ);
    FiltQIsBandWidthCheck.checked := FiltQIsBandWidth;
    FiltBidirectionalCheck.checked := FiltBidirectional;
  end;
end;     

procedure TFilterForm.DefBtnClick(Sender: TObject);
begin
  SetFiltDefaults(gP.F);
  WritePrefs;
end;

procedure TFilterForm.FormShow(Sender: TObject);
begin
  WritePrefs;
  FiltTypeDropChange(nil);
end;

procedure TFilterForm.FiltTypeDropChange(Sender: TObject);
begin
  FiltDBGainEdit.visible :=FiltTypeDrop.ItemIndex >=  kPeaking;
  GainLabel.Visible := FiltDBGainEdit.visible;
end;

end.
