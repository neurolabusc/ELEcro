unit about_form;

interface

uses
    {$IFDEF Win32}
  Windows,  Messages,ShellAPI,
{$ELSE}
  LMessages, LCLType,
{$ENDIF}
{$IFDEF FPC} LResources,{$ENDIF}
   SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TAboutForm = class(TForm)
    Label2: TLabel;
    Panel1: TPanel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation
{$IFNDEF FPC}{$R *.dfm}{$ELSE}{$R *.lfm}{$ENDIF}

procedure TAboutForm.FormShow(Sender: TObject);
begin
//Image1.Picture.Icon:=Application.Icon;
end;

procedure TAboutForm.Label1Click(Sender: TObject);
begin
{$IFDEF Win32}
  ShellExecute (0, Nil, 'http://logicnet.dk/reports', Nil, Nil, SW_ShowDefault);
{$ENDIF}
end;

procedure TAboutForm.Label2Click(Sender: TObject);
begin
{$IFDEF Win32}
  ShellExecute (0, Nil, 'http://www.mricro.com/', Nil, Nil, SW_ShowDefault);
{$ENDIF}

end;

end.
