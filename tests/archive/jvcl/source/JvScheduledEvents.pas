{-----------------------------------------------------------------------------

 Project JEDI Visible Component Library (J-VCL)

 The contents of this file are subject to the Mozilla Public License Version
 1.1 (the "License"); you may not use this file except in compliance with the
 License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 the specific language governing rights and limitations under the License.

 The Initial Developer of the Original Code is Marcel Bestebroer
  <marcelb@zeelandnet.nl>.
 Portions created by Marcel Bestebroer are Copyright (C) 2000 - 2002 mbeSoft.
 All Rights Reserved.

 ******************************************************************************

 Event scheduling component. Allows to schedule execution of events, with
 optional recurring schedule options.

 !!! REQUIRES JCL 1.22 OR HIGHER !!!

 You may retrieve the latest version of this file at the Project JEDI home
 page, located at http://www.delphi-jedi.org
-----------------------------------------------------------------------------}
unit JvScheduledEvents;

interface

{$I jvcl.inc}

uses
  SysUtils, Windows, Classes, syncobjs, Messages,
  jclRegistry, jclSchedule, JclSynch;

const
  CM_ExecEvent = WM_USER + $1000;

type
  TJvCustomScheduledEvents = class;
  TJvEventCollection = class;
  TJvEventCollectionItem = class;

  TJvCustomScheduledEvents = class(TComponent)
  private
    FAutoSave: Boolean;
    FSaveKey: HKEY;
    FSavePath: string;
    FEvents: TJvEventCollection;
    FOnStartEvent: TNotifyEvent;
    FOnEndEvent: TNotifyEvent;
    FWnd: HWND;
  protected
    procedure DoEndEvent(const Event: TJvEventCollectionItem);
    procedure DoStartEvent(const Event: TJvEventCollectionItem);
    function GetSaveTo: string;
    function GetEvents: TJvEventCollection;
    procedure InitEvents;
    procedure Loaded; override;
    procedure LoadEventStates;
    procedure SaveEventStates;
    procedure SetSaveTo(Value: string);
    procedure SetEvents(Value: TJvEventCollection);
    procedure WndProc(var Message: TMessage); virtual;

    property AutoSave: Boolean read FAutoSave write FAutoSave;
    property OnStartEvent: TNotifyEvent read FOnStartEvent write FOnStartEvent;
    property OnEndEvent: TNotifyEvent read FOnEndEvent write FOnEndEvent;
    property SaveTo: string read GetSaveTo write SetSaveTo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Handle: HWND read FWnd;
    property Events: TJvEventCollection read GetEvents write SetEvents;
  published
  end;

  TJvScheduledEvents = class(TJvCustomScheduledEvents)
  published
    property AutoSave;
    property SaveTo;
    property Events;
    property OnStartEvent;
    property OnEndEvent;
  end;

  TJvEventCollection = class(TOwnedCollection)
  private
  protected
    function GetItem(Index: Integer): TJvEventCollectionItem;
    procedure SetItem(Index: Integer; Value: TJvEventCollectionItem);
  public
    constructor Create(AOwner: TPersistent);

    function Add: TJvEventCollectionItem;
    function Insert(Index: Integer): TJvEventCollectionItem;

    property Items[Index: Integer]: TJvEventCollectionItem read GetItem write SetItem; default;
  end;

  TJvEventCollectionItem = class(TCollectionItem)
  private
    FCountMissedEvents: Boolean;
    FName: string;
    FInitialized: Boolean;
    FOnExecute: TNotifyEvent;
    FSchedule: IJclSchedule;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoExecute;
    function GetDisplayName: string; override;
    function GetNextFire: TTimeStamp;
    procedure Execute; virtual;

    // schedule property readers/writers
    procedure PropDateRead(Reader: TReader; var Stamp: TTimeStamp);
    procedure PropDateWrite(Writer: TWriter; const Stamp: TTimeStamp);

    procedure PropDailyEveryWeekDayRead(Reader: TReader);
    procedure PropDailyEveryWeekDayWrite(Writer: TWriter);
    procedure PropDailyIntervalRead(Reader: TReader);
    procedure PropDailyIntervalWrite(Writer: TWriter);
    procedure PropEndCountRead(Reader: TReader);
    procedure PropEndCountWrite(Writer: TWriter);
    procedure PropEndDateRead(Reader: TReader);
    procedure PropEndDateWrite(Writer: TWriter);
    procedure PropEndTypeRead(Reader: TReader);
    procedure PropEndTypeWrite(Writer: TWriter);
    procedure PropFreqEndTimeRead(Reader: TReader);
    procedure PropFreqEndTimeWrite(Writer: TWriter);
    procedure PropFreqIntervalRead(Reader: TReader);
    procedure PropFreqIntervalWrite(Writer: TWriter);
    procedure PropFreqStartTimeRead(Reader: TReader);
    procedure PropFreqStartTimeWrite(Writer: TWriter);
    procedure PropMonthlyDayRead(Reader: TReader);
    procedure PropMonthlyDayWrite(Writer: TWriter);
    procedure PropMonthlyIndexKindRead(Reader: TReader);
    procedure PropMonthlyIndexKindWrite(Writer: TWriter);
    procedure PropMonthlyIndexValueRead(Reader: TReader);
    procedure PropMonthlyIndexValueWrite(Writer: TWriter);
    procedure PropMonthlyIntervalRead(Reader: TReader);
    procedure PropMonthlyIntervalWrite(Writer: TWriter);
    procedure PropRecurringTypeRead(Reader: TReader);
    procedure PropRecurringTypeWrite(Writer: TWriter);
    procedure PropStartDateRead(Reader: TReader);
    procedure PropStartDateWrite(Writer: TWriter);
    procedure PropWeeklyDaysOfWeekRead(Reader: TReader);
    procedure PropWeeklyDaysOfWeekWrite(Writer: TWriter);
    procedure PropWeeklyIntervalRead(Reader: TReader);
    procedure PropWeeklyIntervalWrite(Writer: TWriter);
    procedure PropYearlyDayRead(Reader: TReader);
    procedure PropYearlyDayWrite(Writer: TWriter);
    procedure PropYearlyIndexKindRead(Reader: TReader);
    procedure PropYearlyIndexKindWrite(Writer: TWriter);
    procedure PropYearlyIndexValueRead(Reader: TReader);
    procedure PropYearlyIndexValueWrite(Writer: TWriter);
    procedure PropYearlyIntervalRead(Reader: TReader);
    procedure PropYearlyIntervalWrite(Writer: TWriter);
    procedure PropYearlyMonthRead(Reader: TReader);
    procedure PropYearlyMonthWrite(Writer: TWriter);

    procedure SetName(Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure LoadState(const TriggerStamp: TTimeStamp; const TriggerCount, DayCount: Integer); virtual;
    procedure SaveState(out TriggerStamp: TTimeStamp; out TriggerCount, DayCount: Integer); virtual;
    procedure Start;
    procedure Stop;

    property Initialized: Boolean read FInitialized;
    property NextFire: TTimeStamp read GetNextFire;
  published
    property CountMissedEvents: Boolean read FCountMissedEvents write FCountMissedEvents default False;
    property Name: string read FName write SetName;
    property Schedule: IJclSchedule read FSchedule write FSchedule stored False;

    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
  end;

implementation

uses
  contnrs, Forms, TypInfo,
  JclRTTI;

{ registry constants }

const
  HKEYNames: array[0..6] of string = (
    'HKEY_CLASSES_ROOT',
    'HKEY_CURRENT_USER',
    'HKEY_LOCAL_MACHINE',
    'HKEY_USERS',
    'HKEY_PERFORMANCE_DATA',
    'HKEY_CURRENT_CONFIG',
    'HKEY_DYN_DATA'
  );

  HKEYShortNames: array[0..6] of string = (
    'HKCR',
    'HKCU',
    'HKLM',
    'HKU',
    'HKPD',
    'HKCC',
    'HKDD'
  );

function HKEYFromStringStart(Value: string): HKEY;
var
  I: Cardinal;
begin
  Result := 0;
  I := Pos('\', Value);
  if I = 0 then
    I := Length(Value) + 1;
  Delete(Value, I, Cardinal(Length(Value)) - I + Cardinal(1));
  for I := High(HKEYNames) downto Low(HKEYNames) do
    if AnsiSameText(HKEYNames[I], Value) or AnsiSameText(HKEYShortNames[I], Value) then
    begin
      Result := I + $80000000;
      Break;
    end;
end;

function StringFromHKEY(const Key: HKEY; const UseShortName: Boolean): string;
begin
  if UseShortName then
    Result := HKEYShortNames[KEY - $80000000]
  else
    Result := HKEYNames[KEY - $80000000];
end;

{ TScheduleThread }

type
  TScheduleThread = class(TThread)
  private
    FCritSect: TCriticalSection;
    FEnded: Boolean;
    FEventComponents: TComponentList;
    FEventIdx: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddEventComponent(const AComp: TJvCustomScheduledEvents);
    procedure RemoveEventComponent(const AComp: TJvCustomScheduledEvents);
    procedure Lock;
    procedure Unlock;

    property Ended: Boolean read FEnded;
  end;

{ TScheduleThread }

procedure TScheduleThread.Execute;
var
  TskColl: TJvEventCollection;
  I: Integer;
  SysTime: TSystemTime;
  NowStamp: TTimeStamp;
begin
  FEnded := False;
  while not Terminated do
  begin
    FCritSect.Enter;
    try
      FEventIdx := FEventComponents.Count - 1;
      while (FEventIdx > -1) and not Terminated do
      begin
        GetLocalTime(SysTime);
        NowStamp := DateTimeToTimeStamp(Now);
        with SysTime do
          NowStamp.Time := wHour * 3600000 + wMinute * 60000 + wSecond * 1000 + wMilliseconds;
        TskColl := TJvCustomScheduledEvents(FEventComponents[FEventIdx]).Events;
        I := 0;
        while (I < TskColl.Count) and not Terminated do
        begin
          if TskColl[I].Initialized and (CompareTimeStamps(NowStamp, TskColl[I].NextFire) >= 0) then
            PostMessage(TJvCustomScheduledEvents(FEventComponents[FEventIdx]).Handle, CM_ExecEvent, Integer(TskColl[I]), 0);
          Inc(I);
        end;
        Dec(FEventIdx);
      end;
    finally
      FCritSect.Leave;
    end;
    if not Terminated then
      Sleep(1);
  end;
  FEnded := True;
end;

constructor TScheduleThread.Create;
begin
  inherited Create(True);
  FCritSect := TCriticalSection.Create;
  FEventComponents := TComponentList.Create(False);
end;

destructor TScheduleThread.Destroy;
begin
  inherited Destroy;
  Suspend;
  FEventComponents.Free;
end;

procedure TScheduleThread.AddEventComponent(const AComp: TJvCustomScheduledEvents);
begin
  FCritSect.Enter;
  try
    if FEventComponents.IndexOf(AComp) = -1 then
    begin
      FEventComponents.Add(AComp);
      if Suspended then
        Resume;
    end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TScheduleThread.RemoveEventComponent(const AComp: TJvCustomScheduledEvents);
begin
  FCritSect.Enter;
  try
    FEventComponents.Remove(AComp);
  finally
    FCritSect.Leave;
  end;
end;

procedure TScheduleThread.Lock;
begin
  FCritSect.Enter;
end;

procedure TScheduleThread.Unlock;
begin
  FCritSect.Leave;
end;

{ TScheduleThread instance }

var
  GScheduleThread: TScheduleThread = nil;

function ScheduleThread: TScheduleThread;
begin
  if GScheduleThread = nil then
    GScheduleThread := TScheduleThread.Create;
  Result := GScheduleThread;
end;


{ TOpenReader }

type
  TOpenReader = class(TReader);

{ TOpenWriter }

type
  TOpenWriter = class(TWriter)
  protected
    procedure WriteSet(SetType: Pointer; Value: Integer);
  end;

// Copied from D5 Classes.pas and modified a bit.

procedure TOpenWriter.WriteSet(SetType: Pointer; Value: Integer);
var
  I: Integer;
  BaseType: PTypeInfo;
begin
  BaseType := GetTypeData(SetType)^.CompType^;
  WriteValue(vaSet);
  for I := 0 to SizeOf(TIntegerSet) * 8 - 1 do
    if I in TIntegerSet(Value) then WriteStr(GetEnumName(BaseType, I));
  WriteStr('');
end;

{ TJvCustomScheduledEvents }

const
  ElementSize = ((SizeOf(Cardinal) * 2) + SizeOf(TTimeStamp));

procedure TJvCustomScheduledEvents.DoEndEvent(const Event: TJvEventCollectionItem);
begin
  if @OnEndEvent <> nil then
    OnEndEvent(Event);
end;

procedure TJvCustomScheduledEvents.DoStartEvent(const Event: TJvEventCollectionItem);
begin
  if @OnStartEvent <> nil then
    OnStartEvent(Event);
end;

function TJvCustomScheduledEvents.GetSaveTo: string;
begin
  Result := StringFromHKEY(FSaveKey, True);
  if FSavePath <> '' then
    Result := Result + '\' + FSavePath;
end;

function TJvCustomScheduledEvents.GetEvents: TJvEventCollection;
begin
  Result := FEvents;
end;

procedure TJvCustomScheduledEvents.InitEvents;
var
  I: Integer;
begin
  for I := 0 to FEvents.Count - 1 do
  begin
    if not FEvents[I].Initialized then
      FEvents[I].Start;
  end;
end;

procedure TJvCustomScheduledEvents.Loaded;
begin
  if not (csDesigning in ComponentState) then
  begin
    {$IFNDEF COMPILER6_UP}
    FWnd := AllocateHWnd(WndProc);
    {$ELSE}
    FWnd := Classes.AllocateHWnd(WndProc);
    {$ENDIF COMPILER6_UP}
    if AutoSave then
      LoadEventStates;
    InitEvents;
    ScheduleThread.AddEventComponent(Self);
  end;
end;

procedure TJvCustomScheduledEvents.LoadEventStates;
var
  SubKey: string;
  EventNames: TStrings;
  I: Integer;
  IEvents: Integer;
  EventKey: string;
  Stamp: TTimeStamp;
  TriggerCount: Integer;
  DayCount: Integer;
begin
  SubKey := FSavePath + '\' + Name + '.Events';
  if RegKeyExists(FSaveKey, SubKey) then
  begin
    EventNames := TStringList.Create;
    try
      RegGetKeyNames(FSaveKey, SubKey, EventNames);
      for I := 0 to EventNames.Count - 1 do
      begin
        IEvents := FEvents.Count - 1;
        while (IEvents >= 0) and not AnsiSameText(EventNames[I], FEvents[IEvents].Name) do
          Dec(IEvents);
        if IEvents >= 0 then
        begin
          EventKey := SubKey + '\' + EventNames[I];
          Stamp.Date := RegReadInteger(FSaveKey, EventKey, 'Stamp.Date');
          Stamp.Time := RegReadInteger(FSaveKey, EventKey, 'Stamp.Time');
          TriggerCount := RegReadInteger(FSaveKey, EventKey, 'TriggerCount');
          DayCount := RegReadInteger(FSaveKey, EventKey, 'DayCount');
          FEvents[IEvents].LoadState(Stamp, TriggerCount, DayCount);
        end;
      end;
    finally
      EventNames.Free;
    end;
  end;
end;

procedure TJvCustomScheduledEvents.SaveEventStates;
var
  SubKey: string;
  I: Integer;
  EventKey: string;
  Stamp: TTimeStamp;
  TriggerCount: Integer;
  DayCount: Integer;
  StampDate: Integer;
  StampTime: Integer;
begin
  SubKey := FSavePath + '\' + Name + '.Events';
  if RegKeyExists(FSaveKey, SubKey) then
    RegDeleteKeyTree(FSaveKey, SubKey);
  RegCreateKey(FSaveKey, SubKey, '');
  for I := 0 to FEvents.Count - 1 do
  begin
    EventKey := SubKey + '\' + FEvents[I].Name;
    RegCreateKey(FSaveKey, EventKey, '');
    FEvents[I].SaveState(Stamp, TriggerCount, DayCount);
    StampDate := Stamp.Date;
    StampTime := Stamp.Time;
    RegWriteInteger(FSaveKey, EventKey, 'Stamp.Date', StampDate);
    RegWriteInteger(FSaveKey, EventKey, 'Stamp.Time', StampTime);
    RegWriteInteger(FSaveKey, EventKey, 'TriggerCount', TriggerCount);
    RegWriteInteger(FSaveKey, EventKey, 'DayCount', DayCount);
  end;
end;

procedure TJvCustomScheduledEvents.SetSaveTo(Value: string);
begin
  Value := Trim(Value);
  FSaveKey := HKEYFromStringStart(Value);
  if FSaveKey = 0 then
    FSaveKey := HKEY_CURRENT_USER
  else
  begin
    if AnsiSameText(Copy(Value, 1, 4), 'HKEY') then
      Delete(Value, 1, Length(StringFromHKEY(FSaveKey, False)) + 1)
    else
      Delete(Value, 1, Length(StringFromHKEY(FSaveKey, True)) + 1);
  end;
  FSavePath := Value;
end;

procedure TJvCustomScheduledEvents.SetEvents(Value: TJvEventCollection);
begin
  FEvents.Assign(Value);
end;

procedure TJvCustomScheduledEvents.WndProc(var Message: TMessage);
begin
  if Message.Msg = CM_ExecEvent then
  begin
    DoStartEvent(TJvEventCollectionItem(Message.WParam));
    TJvEventCollectionItem(Message.WParam).Execute;
    DoEndEvent(TJvEventCollectionItem(Message.WParam));
    Message.Result := 1;
  end
  else
    inherited;
end;

constructor TJvCustomScheduledEvents.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSaveKey := HKEY_CURRENT_USER;
  FEvents := TJvEventCollection.Create(Self);
end;

destructor TJvCustomScheduledEvents.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    ScheduleThread.RemoveEventComponent(Self);
    if AutoSave then
      SaveEventStates;
    {$IFNDEF COMPILER6_UP}
    DeallocateHWnd(FWnd);
    {$ELSE}
    Classes.DeallocateHWnd(FWnd);
    {$ENDIF COMPILER6_UP}
  end;
  FEvents.Free;
  inherited Destroy;
end;

{ TJvEventCollection }

function TJvEventCollection.GetItem(Index: Integer): TJvEventCollectionItem;
begin
  Result := TJvEventCollectionItem(inherited Items[Index]);
end;

procedure TJvEventCollection.SetItem(Index: Integer; Value: TJvEventCollectionItem);
begin
  inherited Items[Index] := Value;
end;

constructor TJvEventCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TJvEventCollectionItem);
end;

function TJvEventCollection.Add: TJvEventCollectionItem;
begin
  Result := TJvEventCollectionItem(inherited Add);
end;

function TJvEventCollection.Insert(Index: Integer): TJvEventCollectionItem;
begin
  Result := TJvEventCollectionItem(inherited Insert(Index));
end;

{ TJvEventCollectionItem }

procedure TJvEventCollectionItem.DefineProperties(Filer: TFiler);
var
  SingleShot: Boolean;
  DailySched: Boolean;
  WeeklySched: Boolean;
  MonthlySched: Boolean;
  YearlySched: Boolean;
  MIK: TScheduleIndexKind;
  YIK: TScheduleIndexKind;
begin
  // Determine settings to determine writing properties.
  SingleShot := Schedule.RecurringType = srkOneShot;
  DailySched := Schedule.RecurringType = srkDaily;
  WeeklySched := Schedule.RecurringType = srkWeekly;
  MonthlySched := Schedule.RecurringType = srkMonthly;
  YearlySched := Schedule.RecurringType = srkYearly;
  if MonthlySched then
    MIK := (Schedule as IJclMonthlySchedule).IndexKind
  else
    MIK := sikNone;
  if YearlySched then
    YIK := (Schedule as IJclYearlySchedule).IndexKind
  else
    YIK := sikNone;

  // Standard properties
  Filer.DefineProperty('StartDate', PropStartDateRead, PropStartDateWrite, True);
  Filer.DefineProperty('RecurringType', PropRecurringTypeRead, PropRecurringTypeWrite, not SingleShot);
  Filer.DefineProperty('EndType', PropEndTypeRead, PropEndTypeWrite, not SingleShot);
  Filer.DefineProperty('EndDate', PropEndDateRead, PropEndDateWrite, not SingleShot and
    (Schedule.EndType = sekDate));
  Filer.DefineProperty('EndCount', PropEndCountRead, PropEndCountWrite, not SingleShot and
    (Schedule.EndType in [sekTriggerCount, sekDayCount]));

  // Daily frequency properties
  Filer.DefineProperty('Freq_StartTime', PropFreqStartTimeRead, PropFreqStartTimeWrite,
    not SingleShot);
  Filer.DefineProperty('Freq_EndTime', PropFreqEndTimeRead, PropFreqEndTimeWrite, not SingleShot);
  Filer.DefineProperty('Freq_Interval', PropFreqIntervalRead, PropFreqIntervalWrite,
    not SingleShot);

  // Daily schedule properties
  Filer.DefineProperty('Daily_EveryWeekDay', PropDailyEveryWeekDayRead, PropDailyEveryWeekDayWrite,
    DailySched);
  Filer.DefineProperty('Daily_Interval', PropDailyIntervalRead, PropDailyIntervalWrite,
    DailySched and not (Schedule as IJclDailySchedule).EveryWeekDay);

  // Weekly schedule properties
  Filer.DefineProperty('Weekly_DaysOfWeek', PropWeeklyDaysOfWeekRead, PropWeeklyDaysOfWeekWrite,
    WeeklySched);
  Filer.DefineProperty('Weekly_Interval', PropWeeklyIntervalRead, PropWeeklyIntervalWrite,
    WeeklySched);

  // Monthly schedule properties
  Filer.DefineProperty('Monthly_IndexKind', PropMonthlyIndexKindRead, PropMonthlyIndexKindWrite,
    MonthlySched);
  Filer.DefineProperty('Monthly_IndexValue', PropMonthlyIndexValueRead, PropMonthlyIndexValueWrite,
    MonthlySched and (MIK in [sikDay .. sikSunday]));
  Filer.DefineProperty('Monthly_Day', PropMonthlyDayRead, PropMonthlyDayWrite, MonthlySched and
    (MIK in [sikNone]));
  Filer.DefineProperty('Monthly_Interval', PropMonthlyIntervalRead, PropMonthlyIntervalWrite,
    MonthlySched);

  // Yearly schedule properties
  Filer.DefineProperty('Yearly_IndexKind', PropYearlyIndexKindRead, PropYearlyIndexKindWrite,
    YearlySched);
  Filer.DefineProperty('Yearly_IndexValue', PropYearlyIndexValueRead, PropYearlyIndexValueWrite,
    YearlySched and (YIK in [sikDay .. sikSunday]));
  Filer.DefineProperty('Yearly_Day', PropYearlyDayRead, PropYearlyDayWrite, YearlySched and
    (YIK in [sikNone, sikDay]));
  Filer.DefineProperty('Yearly_Month', PropYearlyMonthRead, PropYearlyMonthWrite, YearlySched);
  Filer.DefineProperty('Yearly_Interval', PropYearlyIntervalRead, PropYearlyIntervalWrite,
    YearlySched);
end;

procedure TJvEventCollectionItem.DoExecute;
begin
  if @FOnExecute <> nil then
    OnExecute(Self);
end;

function TJvEventCollectionItem.GetDisplayName: string;
begin
  Result := Name;
end;

function TJvEventCollectionItem.GetNextFire: TTimeStamp;
begin
  Result := Schedule.LastTriggered;
end;

procedure TJvEventCollectionItem.Execute;
begin
  if IsNullTimeStamp(Schedule.NextEventFromNow(CountMissedEvents)) then
    Stop;
  DoExecute;
end;

procedure TJvEventCollectionItem.PropDateRead(Reader: TReader; var Stamp: TTimeStamp);
var
  Str: string;
  Y: Integer;
  M: Integer;
  D: Integer;
  H: Integer;
  Min: Integer;
  MSecs: Integer;
begin
  Str := Reader.ReadString;
  Y := StrToInt(Copy(Str, 1, 4));
  M := StrToInt(Copy(Str, 6, 2));
  D := StrToInt(Copy(Str, 9, 2));
  H := StrToInt(Copy(Str, 12, 2));
  Min := StrToInt(Copy(Str, 15, 2));
  MSecs := StrToInt(Copy(Str, 18, 2)) * 1000 + StrToInt(Copy(Str, 21, 3));

  Stamp := DateTimeToTimeStamp(EncodeDate(Y, M, D));
  Stamp.Time := H * 3600000 + MIn * 60000 + MSecs;
end;

procedure TJvEventCollectionItem.PropDateWrite(Writer: TWriter; const Stamp: TTimeStamp);
var
  TmpDate: TDateTime;
  Y: Word;
  M: Word;
  D: Word;
  MSecs: Integer;
begin
  TmpDate := TimeStampToDateTime(Stamp);
  DecodeDate(TmpDate, Y, M, D);
  MSecs := Stamp.Time;
  Writer.WriteString(Format('%.4d/%.2d/%.2d %.2d:%.2d:%.2d.%.3d',
    [Y,
     M,
     D,
     (MSecs div 3600000) mod 24,
     (MSecs div 60000) mod 60,
     (MSecs div 1000) mod 60,
     MSecs mod 1000]));
end;

procedure TJvEventCollectionItem.PropDailyEveryWeekDayRead(Reader: TReader);
begin
  (Schedule as IJclDailySchedule).EveryWeekDay := Reader.ReadBoolean;
end;

procedure TJvEventCollectionItem.PropDailyEveryWeekDayWrite(Writer: TWriter);
begin
  Writer.WriteBoolean((Schedule as IJclDailySchedule).EveryWeekDay);
end;

procedure TJvEventCollectionItem.PropDailyIntervalRead(Reader: TReader);
begin
  (Schedule as IJclDailySchedule).Interval := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropDailyIntervalWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclDailySchedule).Interval);
end;

procedure TJvEventCollectionItem.PropEndCountRead(Reader: TReader);
begin
  Schedule.EndCount := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropEndCountWrite(Writer: TWriter);
begin
  Writer.WriteInteger(Schedule.EndCount);
end;

procedure TJvEventCollectionItem.PropEndDateRead(Reader: TReader);
var
  TmpStamp: TTimeStamp;
begin
  PropDateRead(Reader, TmpStamp);
  Schedule.EndDate := TmpStamp;
end;

procedure TJvEventCollectionItem.PropEndDateWrite(Writer: TWriter);
begin
  PropDateWrite(Writer, Schedule.EndDate);
end;

procedure TJvEventCollectionItem.PropEndTypeRead(Reader: TReader);
begin
  Schedule.EndType := TScheduleEndKind(GetEnumValue(TypeInfo(TScheduleEndKind), Reader.ReadIdent));
end;

procedure TJvEventCollectionItem.PropEndTypeWrite(Writer: TWriter);
begin
  Writer.WriteIdent(GetEnumName(TypeInfo(TScheduleEndKind), Ord(Schedule.EndType)));
end;

procedure TJvEventCollectionItem.PropFreqEndTimeRead(Reader: TReader);
begin
  (Schedule as IJclScheduleDayFrequency).EndTime := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropFreqEndTimeWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclScheduleDayFrequency).EndTime);
end;

procedure TJvEventCollectionItem.PropFreqIntervalRead(Reader: TReader);
begin
  (Schedule as IJclScheduleDayFrequency).Interval := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropFreqIntervalWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclScheduleDayFrequency).Interval);
end;

procedure TJvEventCollectionItem.PropFreqStartTimeRead(Reader: TReader);
begin
  (Schedule as IJclScheduleDayFrequency).StartTime := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropFreqStartTimeWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclScheduleDayFrequency).StartTime);
end;

procedure TJvEventCollectionItem.PropMonthlyDayRead(Reader: TReader);
begin
  (Schedule as IJclMonthlySchedule).Day := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropMonthlyDayWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclMonthlySchedule).Day);
end;

procedure TJvEventCollectionItem.PropMonthlyIndexKindRead(Reader: TReader);
begin
  (Schedule as IJclMonthlySchedule).IndexKind :=
    TScheduleIndexKind(GetEnumValue(TypeInfo(TScheduleIndexKind), Reader.ReadIdent));
end;

procedure TJvEventCollectionItem.PropMonthlyIndexKindWrite(Writer: TWriter);
begin
  Writer.WriteIdent(GetEnumName(TypeInfo(TScheduleIndexKind),
    Ord((Schedule as IJclMonthlySchedule).IndexKind)));
end;

procedure TJvEventCollectionItem.PropMonthlyIndexValueRead(Reader: TReader);
begin
  (Schedule as IJclMonthlySchedule).IndexValue := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropMonthlyIndexValueWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclMonthlySchedule).IndexValue);
end;

procedure TJvEventCollectionItem.PropMonthlyIntervalRead(Reader: TReader);
begin
  (Schedule as IJclMonthlySchedule).Interval := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropMonthlyIntervalWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclMonthlySchedule).Interval);
end;

procedure TJvEventCollectionItem.PropRecurringTypeRead(Reader: TReader);
begin
  Schedule.RecurringType :=
    TScheduleRecurringKind(GetEnumValue(TypeInfo(TScheduleRecurringKind), Reader.ReadIdent));
end;

procedure TJvEventCollectionItem.PropRecurringTypeWrite(Writer: TWriter);
begin
  Writer.WriteIdent(GetEnumName(TypeInfo(TScheduleRecurringKind), Ord(Schedule.RecurringType)));
end;

procedure TJvEventCollectionItem.PropStartDateRead(Reader: TReader);
var
  TmpStamp: TTimeStamp;
begin
  PropDateRead(Reader, TmpStamp);
  Schedule.StartDate := TmpStamp;
end;

procedure TJvEventCollectionItem.PropStartDateWrite(Writer: TWriter);
begin
  PropDateWrite(Writer, Schedule.StartDate);
end;

procedure TJvEventCollectionItem.PropWeeklyDaysOfWeekRead(Reader: TReader);
var
  TempVal: TScheduleWeekDays;
begin
  JclIntToSet(TypeInfo(TScheduleWeekDays), TempVal,
    TOpenReader(Reader).ReadSet(TypeInfo(TScheduleWeekDays)));
  (Schedule as IJclWeeklySchedule).DaysOfWeek := TempVal;
end;

procedure TJvEventCollectionItem.PropWeeklyDaysOfWeekWrite(Writer: TWriter);
var
  TempVar: TScheduleWeekDays;
begin
  TempVar := (Schedule as IJclWeeklySchedule).DaysOfWeek;
  TOpenWriter(Writer).WriteSet(TypeInfo(TScheduleWeekDays),
    JclSetToInt(TypeInfo(TScheduleWeekDays), TempVar));
end;

procedure TJvEventCollectionItem.PropWeeklyIntervalRead(Reader: TReader);
begin
  (Schedule as IJclWeeklySchedule).Interval := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropWeeklyIntervalWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclWeeklySchedule).Interval);
end;

procedure TJvEventCollectionItem.PropYearlyDayRead(Reader: TReader);
begin
  (Schedule as IJclYearlySchedule).Day := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropYearlyDayWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclYearlySchedule).Day);
end;

procedure TJvEventCollectionItem.PropYearlyIndexKindRead(Reader: TReader);
begin
  (Schedule as IJclYearlySchedule).IndexKind :=
    TScheduleIndexKind(GetEnumValue(TypeInfo(TScheduleIndexKind), Reader.ReadIdent));
end;

procedure TJvEventCollectionItem.PropYearlyIndexKindWrite(Writer: TWriter);
begin
  Writer.WriteIdent(GetEnumName(TypeInfo(TScheduleIndexKind),
    Ord((Schedule as IJclYearlySchedule).IndexKind)));
end;

procedure TJvEventCollectionItem.PropYearlyIndexValueRead(Reader: TReader);
begin
  (Schedule as IJclYearlySchedule).IndexValue := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropYearlyIndexValueWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclYearlySchedule).IndexValue);
end;

procedure TJvEventCollectionItem.PropYearlyIntervalRead(Reader: TReader);
begin
  (Schedule as IJclYearlySchedule).Interval := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropYearlyIntervalWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclYearlySchedule).Interval);
end;

procedure TJvEventCollectionItem.PropYearlyMonthRead(Reader: TReader);
begin
  (Schedule as IJclYearlySchedule).Month := Reader.ReadInteger;
end;

procedure TJvEventCollectionItem.PropYearlyMonthWrite(Writer: TWriter);
begin
  Writer.WriteInteger((Schedule as IJclYearlySchedule).Month);
end;

procedure TJvEventCollectionItem.SetName(Value: string);
begin
  if FName <> Value then
  begin
    FName := Value;
    Changed(False);
  end;
end;

constructor TJvEventCollectionItem.Create(Collection: TCollection);
var
  NewName: string;
  I: Integer;
  J: Integer;

  function NewNameIsUnique: Boolean;
  begin
    with TJvEventCollection(Collection) do
    begin
      J := Count - 1;
      while (J >= 0) and not AnsiSameText(Items[J].Name, NewName + IntToStr(I)) do
        Dec(J);
      Result := J < 0;
    end;
  end;

  procedure CreateNewName;
  begin
    NewName := 'Event';
    I := 0;
    repeat
      Inc(I);
    until NewNameIsUnique;
  end;

begin
  ScheduleThread.Lock;
  try
    if csDesigning in TComponent(TJvEventCollection(Collection).GetOwner).ComponentState then
      CreateNewName
    else
      NewName := '';
    inherited Create(Collection);
    FSchedule := CreateSchedule;
    if NewName <> '' then
      Name := NewName + IntToStr(I);
  finally
    ScheduleThread.Unlock;
  end;
end;

destructor TJvEventCollectionItem.Destroy;
begin
  ScheduleThread.Lock;
  try
    inherited Destroy;
  finally
    ScheduleThread.Unlock;
  end;
end;

procedure TJvEventCollectionItem.LoadState(const TriggerStamp: TTimeStamp; const TriggerCount, DayCount: Integer);
begin
  Schedule.InitToSavedState(TriggerStamp, TriggerCount, DayCount);
  FInitialized := True;
  if IsNullTimeStamp(TriggerStamp) or
      (CompareTimeStamps(TriggerStamp, DateTimeToTimeStamp(Now)) < 0) then
    Schedule.NextEventFromNow(CountMissedEvents);
end;

procedure TJvEventCollectionItem.SaveState(out TriggerStamp: TTimeStamp; out TriggerCount, DayCount: Integer);
begin
  TriggerStamp := NextFire;
  TriggerCount := Schedule.TriggerCount;
  DayCount := Schedule.DayCount;
end;

procedure TJvEventCollectionItem.Start;
begin
  Schedule.NextEventFromNow(CountMissedEvents);
  FInitialized := True;
end;

procedure TJvEventCollectionItem.Stop;
begin
  FInitialized := False;
end;

initialization

finalization
  if GScheduleThread <> nil then
  begin
    if ScheduleThread.Suspended then
      ScheduleThread.Resume;
    ScheduleThread.FreeOnTerminate := False;
    ScheduleThread.Terminate;
    while not ScheduleThread.Ended do Application.ProcessMessages;
    FreeAndNil(GScheduleThread);
  end;
end.
