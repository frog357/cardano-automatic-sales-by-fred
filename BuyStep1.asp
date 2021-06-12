<% Option Explicit %><%
Function RndInt(Lower, Upper)
  Randomize Timer + 113
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
  Const ForAppending = 8
  Dim objFSO, objTextFile
  Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
   If objFSO.FileExists(strFile) = False Then
  Set objTextFile = objFSO.CreateTextFile(strFile, ForWriting)
   Else
  Set objTextFile = objFSO.OpenTextFile(strFile, ForAppending)
   End If
      objTextFile.Write strTXT
      objTextFile.Close
  Set objTextFile = Nothing
  Set objFSO = Nothing
End Function


if len(Application("intaddr")) = 0 Then
  Application("intaddr") = ReadTXTFile(Server.MapPath("./_CurrentSale/Wallets.txt"))
  
end if


Dim myRegExp, FoundMatch, strPaymentDest
Set myRegExp = New RegExp

strPaymentDest = request.form("PayouttAddr")
if len(strPaymentDest) > 0 then
myRegExp.Pattern = "[^a-zA-Z0-9]"
FoundMatch = myRegExp.Test(strPaymentDest)
if FoundMatch = True Then
  Response.Write "Invalid Payment Address - invalid characters"
  Response.End
end if
end if
if NOT len(strPaymentDest) > 33 Then
  Response.Write "Invalid Payment Address - too short - " & strPaymentDest
  Response.End
end if
if len(strPaymentDest) > 119 Then
  Response.Write "Invalid Payment Address - too long"
  Response.End
end if


if instr(1, application("intaddr"), strPaymentDest) > 0 Then
  Response.Write "You tried to give us one of our own addresses, go back and try again."
  Response.END
end if






if strcomp(left(strPaymentDest, 5), "addr1") <> 0 Then
  if strcomp(left(strPaymentDest, 3), "Ae2") <> 0 Then
    if strcomp(left(strPaymentDest, 5), "DdzFF") <> 0 Then
      Response.Write "Invalid Payment Address, supports addr1, Ae2 and DdzFF only!"
      Response.End
    end if
  end if
end if






Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")



'We need to first check for the ip address of this party to see if they have a pending sale to complete.
Dim thisIP
thisIP = ReadTXTFile(Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".busy"))
if len(thisIP) = 0 Then
  ' This is a fresh user, nothing to verify here, just add them to the busy file now.
  WriteTXTFile Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".busy"), NOW()
  if fso.FileExists(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".addr")) = True Then fso.DeleteFile(Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".addr"))
  WriteTXTFile Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".addr"), strPaymentDest
  'Response.Write "new file created with this date:" & NOW()
else
  ' This users has a job pending, let's check how old it is by reading the contents of this file.
  'Response.Write "date of file shows:" & thisIP
  Dim mhowLongAgo
  mhowLongAgo = DateDiff("n", thisIP, now)
  if cLng(mhowLongAgo) < 11 Then
    'response.write "You started another order " & mhowLongAgo & " minutes ago. You can only start an order every 10 minutes. Once you complete the other order, try again in 10-20 seconds."
    'response.END
    'JUST REDIRECT TO THE STEP 2, IT WILL SHOW THEM THE OTHER ORDER UNTIL IT FINISHES!!
  else
    'it's been more than 10 minutes, we will reset this file now.
    WriteTXTFile Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".busy"), NOW()
    if fso.FileExists(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".addr")) = True Then fso.DeleteFile(Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".addr"))
    WriteTXTFile Server.MapPath("ips\" & Request.ServerVariables("remote_addr") & ".addr"), strPaymentDest
  end if 'Check if it's been 10 minutes - time out this transaction.
end if
set fso = nothing
Response.Redirect "BuyStep2.asp"

%>
