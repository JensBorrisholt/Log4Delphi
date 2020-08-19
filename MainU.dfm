object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Main form'
  ClientHeight = 411
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 852
    Height = 411
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 344
    ExplicitTop = 184
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 424
    Top = 104
  end
end
