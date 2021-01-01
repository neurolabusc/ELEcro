unit deb;

interface
uses dialogs, sysutils;
{$DEFINE GUI}

procedure fx (a: double); overload; //fx used to help debugging - reports number values
procedure fx (a,b: double); overload; //fx used to help debugging - reports number values
procedure fx (a,b,c: double); overload; //fx used to help debugging - reports number values
procedure fx (a,b,c,d: double); overload; //fx used to help debugging - reports number values

implementation

procedure fx (a: double); overload; //fx used to help debugging - reports number values
begin
    {$IFDEF GUI}
	showmessage(floattostr(a));
    {$ELSE}
	msg(floattostr(a));
    {$ENDIF}
end;

procedure fx (a,b: double); overload; //fx used to help debugging - reports number values
begin
    {$IFDEF GUI}
	showmessage(floattostr(a)+'x'+floattostr(b));
    {$ELSE}
	msg(floattostr(a)+'x'+floattostr(b));
    {$ENDIF}
end;

procedure fx (a,b,c: double); overload; //fx used to help debugging - reports number values
begin
    {$IFDEF GUI}
	showmessage(floattostr(a)+'x'+floattostr(b)+'x'+floattostr(c));
    {$ELSE}
	msg(floattostr(a)+'x'+floattostr(b)+'x'+floattostr(c));
    {$ENDIF}
end;

procedure fx (a,b,c,d: double); overload; //fx used to help debugging - reports number values
begin
    {$IFDEF GUI}
	showmessage(floattostr(a)+'x'+floattostr(b)+'x'+floattostr(c)+'x'+floattostr(d));
    {$ELSE}
	msg(floattostr(a)+'x'+floattostr(b)+'x'+floattostr(c)+'x'+floattostr(d));
    {$ENDIF}
end;

end.
 