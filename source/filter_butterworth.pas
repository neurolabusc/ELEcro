unit filter_butterworth;
//http://www.mtu-net.ru/aborovsky/acs/index.html
//unit acs_filters;
//http://wiki.lazarus.freepascal.org/ACS
//https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr/components/acs/Src/classes/acs_filters.pas
(*
  this file is a part of audio components suite v 2.3.
  copyright (c) 2002-2005 andrei borovsky. all rights reserved.
  see the license file for more details.
  you can contact me at mail@z0m3ie.de
*)

{$ifdef fpc}
{$mode delphi}
{$endif}

interface

uses
  Classes, SysUtils,  Math, dialogs, deb;

type
  TACSFilterType = (ftBandPass, ftBandReject, ftHighPass, ftLowPass);
  function Butterworth(var FInput: array of single; InSampleRate: double; LowFreq, HighFreq: integer; lFilter: TACSFilterType ): boolean;

implementation
//const BUF_SIZE = $4000;
type
  TBWFilter = record
      a3 : array[0..2] of Double;
      b2 : array[0..1] of Double;
      x0, x1, y0, y1 :  Double;

   end;

  procedure Init (InSampleRate: double; LowFreq, HighFreq : Integer; var FilterType: TACSFilterType; BW: TBWFilter);
  var
    C, D : Double;
  begin
    with BW do begin

    x0 := 0.0;
    x1 := 0.0;
    y0 := 0.0;
    y1 := 0.0;
    case FilterType of
      ftBandPass :
      begin
        C := 1 / Tan(Pi * (HighFreq-LowFreq+1) / InSampleRate);
        D := 2 * Cos(2 * Pi * ((HighFreq+LowFreq) shr 1) / InSampleRate);
        a3[0] := 1 / (1 + C);
        a3[1] := 0.0;
        a3[2] := -a3[0];
        b2[0] := -C * D * a3[0];
        b2[1] := (C - 1) * a3[0];
      end;
      ftBandReject:  // This doesn't seem to work well
      begin
        C := Tan(Pi * (HighFreq-LowFreq+1) / InSampleRate);
        D := 2 * Cos(2 * Pi * ((HighFreq+LowFreq) shr 1) / InSampleRate);
        a3[0] := 1 / (1 + C);
        a3[1] := -D * a3[0];
        a3[2] := a3[0];
        b2[0] := a3[1];
        b2[1] := (1 - C) * a3[0];
      end;
      ftLowPass:
      begin
        C := 1 / Tan(Pi * LowFreq / InSampleRate);
        a3[0] := 1 / (1 + Sqrt(2) * C + C * C);
        a3[1] := 2 * a3[0];
        a3[2] := a3[0];
        b2[0] := 2 * (1 - C * C) * a3[0];
        b2[1] := (1 - Sqrt(2) * C + C * C) * a3[0];
      end;
      ftHighPass:
      begin
        C := Tan(Pi * HighFreq / InSampleRate);
        a3[0] := 1 / (1 + Sqrt(2) * C + C * C);
        a3[1] := -2 * a3[0];
        a3[2] := a3[0];
        b2[0] := 2 * (C * C - 1) * a3[0];
        b2[1] := (1 - Sqrt(2) * C + C * C) * a3[0];
      end;
    end;
    end;//with BW
end;

function Butterworth(var FInput: array of single; InSampleRate: double; LowFreq, HighFreq: integer; lFilter: TACSFilterType ): boolean;
var
    Samples,i : Integer;
    BW: TBWFilter;
    arg, res : Double;
begin

    {Samples := length(FInput);
    for i := 0 to Samples-1 do
      FInput[i] := random(22);
    exit; }

    result := false;
    if (lFilter =  ftBandReject) or (lFilter = ftBandReject) then begin
      if (HighFreq - LowFreq) < 0 then begin
        showmessage('Notch filters require a high filter higher than low frequency.');
        exit;
      end;
      if ((HighFreq - LowFreq) * 2) >= InSampleRate then begin
        showmessage('Nyquist frequency violated: Notch filters require more separation between high and low frequencies.');
        exit;
      end;
    end; //
    Samples := length(FInput);
    if Samples < 2 then
      exit;
    Init (InSampleRate, LowFreq, HighFreq,lFilter,BW);
//fx(BW.a3[0],999);
    //for i := 4 to 5 do
    //    fx( FInput[i]);
    with BW do begin
      for i := 0 to Samples - 1 do begin
          arg := FInput[i];
          res := a3[0] * arg + a3[1] * x0 + a3[2] * x1 -
                 b2[0] * y0 - b2[1] * y1;
          FInput[i] := {Round}(res);
          //fx(arg,res);
          //if (i>=4) and (i<=5)then
          //  fx(arg,res,777);
          x1 := x0;
          x0 := arg;
          y1 := y0;
          y0 := res;
          //FInput[i] := {BW.Amplification *} FInput[i];
      end;//for each sample
    end; //with BW
end;



end.
