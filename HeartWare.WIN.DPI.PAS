UNIT HeartWare.WIN.DPI;

INTERFACE

USES System.Classes,System.SysUtils,
     VCL.Forms;

TYPE
  TCardinalFunc         = TFunc<Cardinal>;
  TWindowsDPI           = CLASS(TThread)
                          STRICT PRIVATE
                            CLASS FUNCTION      IsWin10 : BOOLEAN; INLINE;
                            CLASS FUNCTION      IsWin81 : BOOLEAN; INLINE;
                          PRIVATE
                            DPI                 : Cardinal;
                            Code                : TCardinalFunc;
                            CLASS FUNCTION      Run(Code : TCardinalFunc) : Cardinal;
                          PROTECTED
                            PROCEDURE           Execute; OVERRIDE;
                          PUBLIC
                            CLASS FUNCTION      GetTrueDPI : Cardinal; OVERLOAD;
                            CLASS FUNCTION      GetTrueDPI(M : TMonitor) : Cardinal; OVERLOAD;
                            CLASS FUNCTION      GetTrueDPI(F : TCustomForm) : Cardinal; OVERLOAD; INLINE;
                          PUBLIC
                            CLASS FUNCTION      GetDPI : Cardinal; OVERLOAD;
                            CLASS FUNCTION      GetDPI(M : TMonitor) : Cardinal; OVERLOAD;
                            CLASS FUNCTION      GetDPI(F : TCustomForm) : Cardinal; OVERLOAD;
                          END;

IMPLEMENTATION

USES WinAPI.Windows,WinAPI.ShellScaling;

{ TWindowsDPI }

CLASS FUNCTION TWindowsDPI.Run(Code : TCardinalFunc) : Cardinal;
  VAR
    T   : TWindowsDPI;

  BEGIN
    T:=TWindowsDPI.Create(TRUE);
    TRY
      T.Code:=Code;
      T.FreeOnTerminate:=FALSE;
      T.Resume;
      WHILE NOT T.Terminated DO Sleep(10);
      Result:=T.DPI
    FINALLY
      T.Free
    END
  END;

PROCEDURE TWindowsDPI.Execute;
  VAR
    OLD : DPI_AWARENESS_CONTEXT;

  BEGIN
    TRY
      TRY
        IF IsWin10 THEN
          OLD:=SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
        ELSE
          OLD:=NIL;
        TRY
          DPI:=Code
        FINALLY
          IF Assigned(OLD) THEN SetThreadDpiAwarenessContext(OLD)
        END
      EXCEPT
        DPI:=0
      END
    FINALLY
      Terminate
    END
  END;

CLASS FUNCTION TWindowsDPI.GetDPI : Cardinal;
  BEGIN
    Result:=GetDeviceCaps(GetDC(0),LOGPIXELSX)
  END;

CLASS FUNCTION TWindowsDPI.GetDPI(M : TMonitor) : Cardinal;
  VAR
    X,Y : Cardinal;

  BEGIN
    IF IsWin81 AND (GetDpiForMonitor(M.Handle,MDT_EFFECTIVE_DPI,X,Y)=S_OK) THEN
      Result:=X
    ELSE
      Result:=GetDPI
  END;

CLASS FUNCTION TWindowsDPI.GetTrueDPI(M : TMonitor) : Cardinal;
  BEGIN
    Result:=Run(FUNCTION : Cardinal
                  BEGIN
                    Result:=GetDPI(M)
                  END)
  END;

CLASS FUNCTION TWindowsDPI.GetTrueDPI : Cardinal;
  BEGIN
    Result:=Run(FUNCTION : Cardinal
                  BEGIN
                    Result:=GetDPI
                  END)
  END;

CLASS FUNCTION TWindowsDPI.GetDPI(F : TCustomForm) : Cardinal;
  BEGIN
    Result:=GetDPI(F.Monitor)
  END;

CLASS FUNCTION TWindowsDPI.GetTrueDPI(F : TCustomForm) : Cardinal;
  BEGIN
    Result:=GetTrueDPI(F.Monitor)
  END;

CLASS FUNCTION TWindowsDPI.IsWin10 : BOOLEAN;
  BEGIN
    Result:=CheckWin32Version(10)
  END;

CLASS FUNCTION TWindowsDPI.IsWin81 : BOOLEAN;
  BEGIN
    Result:=CheckWin32Version(6,3)
  END;

END.

