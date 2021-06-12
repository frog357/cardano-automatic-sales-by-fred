<% Option Explicit %><%
Function RndInt(Lower, Upper)
  Randomize Timer + 443
  RndInt = Int((Upper-Lower+1)*Rnd+Lower)
End Function
Function RndSlot()
  iSlot = RndInt(1000,9999)
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

Function ListFolder(path) 
  Dim fs, newPath, child, folder, outList, addrOut
  Set fs   = CreateObject("Scripting.FileSystemObject")
  newPath = Server.MapPath(path)
  set folder = fs.GetFolder(newPath)
  For Each child In folder.Files
      'Only add the jobs where the extensions are .work not .busy
      if instr(1, child.Name, ".busy") > 0 then
        addrOut = ReadTXTFile(server.mappath(replace(child.name, ".busy", ".addr")))
        if len(addrOut) > 0 then outList = outList & replace(child.Name, ".busy", "") & "." & addrOut & vbCrlf
      end if
  Next
  Set fs = Nothing
  ListFolder = outList
End Function

Dim listOfSpots
listOfSpots = ListFolder(".")
Response.Write listOfSpots

%>
