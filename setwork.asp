<% Option Explicit %><%

'This page is lacking any security to prevent abuse.
'The only security is obscurity.
'If you rename this file and update the script you will have some very minimal level of protection.



Function RndInt(Lower, Upper)
  Randomize Timer + 322
  RndInt = Int((Upper-Lower+1)*Rnd+Lower)
End Function


Dim thisWorkSlot
thisWorkSlot = Request.QueryString("i")
if len(thisWorkSlot) > 4 Then response.end
if len(thisWorkSlot) = 0 Then response.end

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
fso.MoveFile Server.MapPath(thisWorkSlot & ".busy"), Server.MapPath(".") & "/" & thisWorkSlot & ".sold"
set fso = nothing
%>
