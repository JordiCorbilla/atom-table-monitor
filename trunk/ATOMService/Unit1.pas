unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls;

type
  TATOMScanner = class(TService)
    Timer1: TTimer;
    procedure ServiceExecute(Sender: TService);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure WriteAtoms;
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ATOMScanner: TATOMScanner;

const
  FileName1 = 'C:\GlobalAtomLog.txt';
  FileName2 = 'C:\RWMAtomLog.txt';

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ATOMScanner.Controller(CtrlCode);
end;

function TATOMScanner.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TATOMScanner.ServiceExecute(Sender: TService);
begin
  Timer1.Enabled := True;
  WriteAtoms();
  while not Terminated do
    ServiceThread.ProcessRequests(True); // wait for termination
  if FileExists(Filename1) then
    DeleteFile(Filename1);
  if FileExists(Filename2) then
    DeleteFile(Filename2);
  Timer1.Enabled := False;
end;

procedure TATOMScanner.WriteAtoms();
var
  i: word;
  cstrAtomName: array [0 .. 1024] of char;
  cstrRWMName: array [0 .. 1024] of char;
  AtomName, RWMName: string;
  len, lenRWM: integer;
  Value: string;
  count: integer;
var
  F: TextFile;
begin
  count := 0;
  AssignFile(F, FileName1);
  try
    Rewrite(F);
    writeln(F, '//GlobalAtom Table ****************************');
    for i := $C000 to $FFFF do
    begin
      Value := '';
      len := GlobalGetAtomName(i, cstrAtomName, 1024);
      if len > 0 then
      begin
        AtomName := StrPas(cstrAtomName);
        SetLength(AtomName, len);
        Value := AtomName;
        Inc(count);
        writeln(F, Format('%X=', [i]) + Value);
      end;
    end;
    writeln(F, '//GlobalAtom Table Total: ' + IntToStr(count) + '****************************');
  finally
    CloseFile(F);
  end;

  Sleep(100);

  count := 0;
  AssignFile(F, FileName2);
  try
    Rewrite(F);
    writeln(F, '//RWM Atom Table ****************************');
    for i := $C000 to $FFFF do
    begin
      Value := '';
      lenRWM := GetClipboardFormatName(i, cstrRWMName, 1024);
      if lenRWM > 0 then
      begin
        RWMName := StrPas(cstrRWMName);
        SetLength(RWMName, lenRWM);
        Value := RWMName;
        Inc(count);
        writeln(F, Format('%X=', [i]) + Value);
      end;
    end;
    writeln(F, '//RWM Table Total: ' + IntToStr(count) + '****************************');
  finally
    CloseFile(F);
  end;
end;

procedure TATOMScanner.Timer1Timer(Sender: TObject);
begin
  try
    WriteAtoms();
  except
    on e: Exception do
      LogMessage(e.Message);
  end;
end;

end.
