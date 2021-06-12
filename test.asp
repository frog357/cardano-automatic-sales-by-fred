<% Option Explicit %><%
Function RndInt(Lower, Upper)
  Randomize Timer + 222
  RndInt = Int((Upper-Lower+1)*Rnd+Lower)
End Function
Function ReadTXTFile(strFile)
  On Error Resume Next
  Dim objFSO, objTextFile, sReadAll
  Const ForReading = 1
  Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
  'Check if file exsists if not...
  Set objTextFile = objFSO.OpenTextFile(strFile, ForReading)
  sReadAll = objTextFile.ReadAll
  'Cleanup objects.
  objTextFile.Close
  Set objTextFile = Nothing
  Set objFSO      = Nothing
  ReadTXTFile = sReadAll
End Function

Function WriteTXTFile(ByVal strFile, ByVal strTXT)
  Const ForWriting = 2
  Dim objFSO, objTextFile
  Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
   If objFSO.FileExists(strFile) = False Then
  Set objTextFile = objFSO.CreateTextFile(strFile, ForWriting)
   Else
  Set objTextFile = objFSO.OpenTextFile(strFile, ForWriting)
   End If
      objTextFile.Write strTXT
      objTextFile.Close
  Set objTextFile = Nothing
  Set objFSO = Nothing
End Function



Dim fso, objTextFile
  Set fso = Server.CreateObject("Scripting.FileSystemObject")

'Make a file.
WriteTXTFile Server.MapPath("test_write.txt"), NOW()


'Move a file.
fso.MoveFile Server.MapPath("test_write.txt"), Server.MapPath("test_write.tx2")

'Delete a file.
if fso.FileExists(Server.MapPath("test_write.tx2")) = True Then
  fso.DeleteFile(Server.MapPath("test_write.tx2"))
end if

Set fso = Nothing


If request.querystring("kill") = "1" Then 
Session("item") = ""
session("tSlot") = ""
end if

Response.Write "Testing OK!"

Dim getBack, theWork
getBack = Session("tSlot")

Response.Write "<br />" & getBack

%>
