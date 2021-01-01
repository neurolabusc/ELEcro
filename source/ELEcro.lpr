program ELEcro;
 {$mode objfpc} {$H+}
uses
  Interfaces,
  Forms,
  eegmain, ave_form,filter_form, about_form, trigger_form;

{$R *.res}


begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAverageForm, AverageForm);
  Application.CreateForm(TFilterForm , FilterForm );
  Application.CreateForm(TAboutForm , AboutForm);
  Application.CreateForm(TTrigger2EventsForm, Trigger2EventsForm);
  Application.Run;
end.

