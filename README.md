Monitoring tool for global atom table and RegisterWindowMessage identifiers.
==============
"An atom table is a system-defined table that stores strings and corresponding identifiers. An application places a string in an atom table and receives a 16-bit integer, called an atom, that can be used to access the string. A string that has been placed in an atom table is called an atom name"
--------------

**Source**: [Microsoft - About Atom tables](http://msdn.microsoft.com/en-us/library/windows/desktop/ms649053(v=vs.85).aspx)

With ATOM table Monitor, all created atoms using [RegisterClass](http://msdn.microsoft.com/en-us/library/windows/desktop/ms633586(v=vs.85).aspx), [RegisterClassEx](http://msdn.microsoft.com/en-us/library/windows/desktop/ms633587(v=vs.85).aspx), [GlobalAddAtom](http://msdn.microsoft.com/en-us/library/windows/desktop/ms649060(v=vs.85).aspx), [AddAtom](http://msdn.microsoft.com/en-us/library/windows/desktop/ms649056(v=vs.85).aspx) or identifiers from [RegisterWindowMessage](http://msdn.microsoft.com/en-us/library/windows/desktop/ms644947(v=vs.85).aspx) functions can be monitored and be sure our applications are not leaking Atoms / identifiers.

[![Downloads](https://img.shields.io/badge/downloads-3k-blue.svg)](https://app.box.com/s/tbmze7klz6j3astnviygwrgkdi4fu7ft) [![Stable Release](https://img.shields.io/badge/version-1.4-blue.svg)](https://app.box.com/s/tbmze7klz6j3astnviygwrgkdi4fu7ft) [![License](https://img.shields.io/badge/license-BDS-blue.svg)](https://app.box.com/s/tbmze7klz6j3astnviygwrgkdi4fu7ft) [![Delphi version](https://img.shields.io/badge/delphi-xe-red.svg)](https://app.box.com/s/tbmze7klz6j3astnviygwrgkdi4fu7ft)

**Related Articles:**
  - [Monitoring Global Atom table part I](http://thundaxsoftware.blogspot.com/2012/02/monitoring-global-atom-table-part-i.html)
  - [Monitoring Global Atom table part II](http://thundaxsoftware.blogspot.com/2012/02/monitoring-global-atom-table-part-ii.html)
  - [Monitoring Global Atom table part III](http://thundaxsoftware.blogspot.com/2012/02/monitoring-global-atom-table-part-iii.html)

**Features:**
  - Monitor Global atom entries from 0xC000 to 0xFFFF using [GlobalGetAtomName](http://msdn.microsoft.com/en-us/library/windows/desktop/ms649063(v=vs.85).aspx).
  - Monitor RegisterWindowMessage atom entries (identifiers) from 0xC000 to 0xFFF using [GetClipboardFormatName](http://msdn.microsoft.com/en-us/library/windows/desktop/ms649040(v=vs.85).aspx).
  - Memory displayed in a nice way using a memory grid.
  - Match pattern using regular expressions.
  - Graph displaying current values.
  - Testing table entries using GlobalAddAtom and RegisterWindowMessage functions.
  - Monitoring user session atoms and Service session atoms.

**Notes:**
  - It uses **C:\** drive for internal use as it is hard-coded. (Be sure you have that drive in your system)

**Global atom table:**
![](http://4.bp.blogspot.com/-D6tRXUP7M0M/T0LAwZpBEWI/AAAAAAAAC5s/DxauJez7r3M/s1600/monitor1.jpg)
**RegisterWindowMessage table:**
![](http://4.bp.blogspot.com/-Ra7SgHtpfEk/T0LAyP_Tm4I/AAAAAAAAC50/t2P3rgKyNzw/s1600/monitor2.jpg)
**Display list of entries:**
![](http://2.bp.blogspot.com/--MXjyf2Uy64/T0LA0mwkGrI/AAAAAAAAC58/lQjr1O8WVNo/s1600/monitor3.jpg)
**Matching string patterns:**
![](http://4.bp.blogspot.com/-o8E5rBf5s4Y/T0LA2JJj0pI/AAAAAAAAC6E/jId5MN2Yq8U/s1600/monitor4.jpg)
**Counters:**
![](http://1.bp.blogspot.com/-0w8YllG0ahk/T0LA3k-j-zI/AAAAAAAAC6M/YuVWBHP_eWc/s1600/monitor5.jpg)
**Test screen:**
![](http://2.bp.blogspot.com/-78qn1E24k1g/T0LA4_FeFvI/AAAAAAAAC6U/jAihiSGuF4Y/s1600/monitor6.jpg)
**Session screen selection:**
![](http://3.bp.blogspot.com/-wMA0s0HxjXI/T0k1SI7ENjI/AAAAAAAAC6s/26_L_TuX8Ec/s1600/v1.4Service.png)
**Monitoring Service session atoms:**
![](http://3.bp.blogspot.com/-RIsOXSEw4BU/T0k3K7DJ5tI/AAAAAAAAC60/ehV0fBX2RQ0/s1600/v1.4RWM.png)

**Scan Atoms method:**
```delphi
procedure ScanAtoms;
var
  i: word;
  cstrAtomName: array [0 .. 1024] of char;
  cstrRWMName: array [0 .. 1024] of char;
  AtomName, RWMName: string;
  len, lenRWM: integer;
  Value: string;
  countAtom, countRWM: integer;
begin
  countAtom := 0;
  countRWM := 0;
  for i := $C000 to $FFFF do
  begin
    Value := '';
    len := GlobalGetAtomName(i, cstrAtomName, 1024);
    lenRWM := GetClipboardFormatName(i, cstrRWMName, 1024);
    if len > 0 then
    begin
      AtomName := StrPas(cstrAtomName);
      SetLength(AtomName, len);
      Value := AtomName;
      Inc(countAtom);
      FATomTable[i - $C000].atom[0] := Value + '  --GlobalAtom';
    end;
    if lenRWM > 0 then
    begin
      RWMName := StrPas(cstrRWMName);
      SetLength(RWMName, lenRWM);
      Value := RWMName;
      Inc(countRWM);
      FATomTable[i - $C000].atom[1] := Value + '  --RWM';
    end;
  end;
end;
```

**Using regular expressions:**
```delphi
function GetColor(Text: string): TColor;
  var
    i: integer;
    perl: TPerlRegEx;
    res: TColor;
  begin
    res := clGray;
    for i := 0 to FListPatterns.count - 1 do
    begin
      perl := TPerlRegEx.Create;
      try
        perl.RegEx := UTF8String(FListPatterns[i].RegularEx);
        perl.Subject := UTF8String(Text);
        if perl.Match then
        begin
          res := FListPatterns[i].color;
          Break;
        end;
      finally
        perl.Free;
      end;
    end;
    result := res;
  end;
```

**Testing:**
```delphi
procedure AddatomClick(Sender: TObject);
var
  i: integer;
begin
  try
    GlobalAddAtom(PChar(getRandomString(Edit4.Text)));
    if GetLastError <> 0 then
    begin
      ShowMessage(IntToStr(GetLastError) + ' ' + SysErrorMessage(GetLastError));
      Break;
    end;
  Except
    on e: exception do
      ShowMessage(e.message + ' ' + IntToStr(GetLastError));
  end;
end;

procedure RWMAddAtom(Sender: TObject);
var
  i: integer;
  myString: string;
begin
  myString := getRandomString(Edit8.Text);
  try
    RegisterWindowMessage(PWideChar(myString));
    if GetLastError <> 0 then
    begin
      ShowMessage(IntToStr(GetLastError) + ' ' + SysErrorMessage(GetLastError));
      Break;
    end;
  Except
    on e: exception do
      ShowMessage(e.message + ' ' + IntToStr(GetLastError));
  end;
end;

function getRandomString(header: string): string;
const
  Chars = '1234567890ABCDEFGHJKLMNPQRSTUVWXYZ!?/*+-';
var
  S: string;
  i, N: integer;
begin
  Randomize;
  S := '';
  for i := 1 to 6 do
  begin
    N := Random(Length(Chars)) + 1;
    S := S + Chars[N];
  end;
  result := header + S;
end;
```

**Testing using RegisterClassEx**
```delphi
procedure btnCreateClick(Sender: TObject);
var
  WC: TWndclassEx;
  atom: word;
begin
  WC.lpszclassName := PWideChar(Edit10.Text);
  WC.cbSize := SizeOf(TWndclassEx);
  WC.style := CS_VREDRAW or CS_HREDRAW;
  WC.lpfnWndProc := @DefWindowProc;
  WC.cbClsExtra := 0;
  WC.cbWndExtra := 0;
  WC.hinstance := hinstance;
  WC.hIcon := Application.Icon.Handle;
  WC.hIconSm := Application.Icon.Handle;
  WC.hCursor := LoadCursor(0, IDC_ARROW);
  WC.lpszMenuName := nil;
  WC.hbrBackground := (COLOR_BACKGROUND + 1);

  atom := RegisterClassEx(WC);
  if atom <> 0 then
    ShowMessage('Atom Created at ' + IntToHex(atom, 4));
end;
```

**Tested under:**
  - Windows Xp, Vista, 7, Server 2003, Server 2008

**Developed under:**
  - Delphi 2010

**StackOverflow entry:**
  - [System Error. Code: 8. Not enough storage is available to process this command](http://stackoverflow.com/questions/507853/system-error-code-8-not-enough-storage-is-available-to-process-this-command/9066509#9066509)

**Microsoft Debug Blog entry:**
  - [Identifying global atom table leaks](http://blogs.msdn.com/b/ntdebugging/archive/2012/01/31/identifying-global-atom-table-leaks.aspx).

## Sponsors
No sponsors yet! Will you be the first?

[![PayPayl donate button](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L5FCF6LX5C9AW "Donate once-off to this project using Paypal")
