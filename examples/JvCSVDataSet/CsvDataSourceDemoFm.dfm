object CsvDataSourceForm: TCsvDataSourceForm
  Left = 179
  Top = 121
  Width = 810
  Height = 638
  Caption = 'Comma Separated Variable File (TJvCsvDataSet) Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 336
    Top = 144
    Width = 299
    Height = 13
    Caption = 'Date Display Format in Grid (does not affect saved CSV format):'
  end
  object DBNavigator1: TDBNavigator
    Left = 24
    Top = 136
    Width = 240
    Height = 25
    DataSource = DataSource1
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 24
    Top = 160
    Width = 754
    Height = 223
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'NAME'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ADDRESS'
        Width = 151
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ADDRESS2'
        Width = 140
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TELEPHONE'
        Width = 140
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'AGE'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LASTPHONECALL'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PRIVATENUMBER'
        Visible = True
      end>
  end
  object Button1: TButton
    Left = 8
    Top = 398
    Width = 265
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'JvCsvDataSet1.AssignToStrings(Memo1.Lines)'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 560
    Top = 398
    Width = 173
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save Now. (aka Flush)'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 426
    Width = 785
    Height = 168
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '<Click the VIEW button to view the results as a CSV ascii file.>')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object Button3: TButton
    Left = 280
    Top = 398
    Width = 265
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'JvCsvDataSet1.AssignFromStrings(Memo1.Lines)'
    TabOrder = 5
    OnClick = Button3Click
  end
  object ComboBox1: TComboBox
    Left = 640
    Top = 136
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    OnChange = ComboBox1Change
    Items.Strings = (
      'yyyy-mm-dd hh:nn:ss'
      'yyyy-mm-dd hh:nn:ss am/pm'
      'mmm dd, yyyy hh:nn:ss am/pm'
      'mm/ddd/yyyy hh:nn:ss'
      'ddd mmm dd, yyyy hh:nn:ss'
      'ddd mmm dd, yyyy hh:nn:ss am/pm')
  end
  object RichEdit1: TRichEdit
    Left = 0
    Top = 0
    Width = 802
    Height = 113
    Align = alTop
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Lines.Strings = (
      'How to use the JvCsvDataSet: '
      
        '(1) Drop  a TJvCsvDataSource, the usual TDataSet, and your favor' +
        'ite data-aware controls, and set up the usual properties. '
      
        '(2)  Set the filename, the CsvFieldDef field (click the '#39'...'#39' bu' +
        'tton), then, if you want field objects, right click on the CSVDa' +
        'taSet and add the '
      
        'field objects in the usual way.  This component does not rely on' +
        ' BDE, ADO, or any external DLL/OCX, so you can create simple dat' +
        'abase '
      
        'applications that run entirely from your EXE with no runtime req' +
        'uirements (if you link the VCL runtime statically).  '
      ''
      
        '*** Comments or Questions? Check the Delphi Jedi VCL Support New' +
        'sgroups. ***')
    ParentFont = False
    ReadOnly = True
    TabOrder = 7
  end
  object DataSource1: TDataSource
    DataSet = JvCsvDataSet1
    Left = 52
    Top = 216
  end
  object JvCsvDataSet1: TJvCsvDataSet
    FileName = 'PhoneList.csv'
    Changed = False
    CsvFieldDef = 
      'NAME,ADDRESS,ADDRESS2,TELEPHONE,AGE:%,LASTPHONECALL:@,PRIVATENUM' +
      'BER:!'
    CsvUniqueKeys = False
    CaseInsensitive = False
    AutoBackupCount = 0
    StoreDefs = True
    Left = 124
    Top = 196
    object JvCsvDataSet1NAME: TStringField
      FieldName = 'NAME'
      Size = 80
    end
    object JvCsvDataSet1ADDRESS: TStringField
      FieldName = 'ADDRESS'
      Size = 80
    end
    object JvCsvDataSet1ADDRESS2: TStringField
      FieldName = 'ADDRESS2'
      Size = 80
    end
    object JvCsvDataSet1TELEPHONE: TStringField
      FieldName = 'TELEPHONE'
      Size = 80
    end
    object JvCsvDataSet1AGE: TIntegerField
      FieldName = 'AGE'
    end
    object JvCsvDataSet1LASTPHONECALL: TDateTimeField
      FieldName = 'LASTPHONECALL'
    end
    object JvCsvDataSet1PRIVATENUMBER: TBooleanField
      FieldName = 'PRIVATENUMBER'
    end
  end
end
