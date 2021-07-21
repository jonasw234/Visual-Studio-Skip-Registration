#SingleInstance Force

Process_Suspend(PID_or_Name){
    PID := (InStr(PID_or_Name,".")) ? ProcExist(PID_or_Name) : PID_or_Name
    h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
    If !h   
        Return -1
    DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
    DllCall("CloseHandle", "Int", h)
}

ProcExist(PID_or_Name=""){
    Process, Exist, % (PID_or_Name="") ? DllCall("GetCurrentProcessID") : PID_or_Name
    Return Errorlevel
}

Loop
{
    Process, Wait, ServiceHub.IdentityHost.exe

    WinWait, ahk_exe devenv.exe
    Process_Suspend("ServiceHub.IdentityHost.exe")
    ; Sometimes the devenv.exe process tree doesn’t close, but ServiceHub.VSDetouredHost.exe is almost always respawned
    Process, Wait, ServiceHub.VSDetouredHost.exe
    
    Process, WaitClose, %ErrorLevel%
    Process, Close, ServiceHub.IdentityHost.exe
}
