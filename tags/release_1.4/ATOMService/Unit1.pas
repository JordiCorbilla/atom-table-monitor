(*
  Copyright (c) 2012, Jordi Corbilla
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  - Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  - Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  - Neither the name of this library nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*)
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
