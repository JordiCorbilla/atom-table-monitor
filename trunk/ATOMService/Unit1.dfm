object ATOMScanner: TATOMScanner
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'ATOMScannerService'
  OnExecute = ServiceExecute
  Height = 150
  Width = 215
  object Timer1: TTimer
    Interval = 10000
    OnTimer = Timer1Timer
    Left = 168
    Top = 16
  end
end
