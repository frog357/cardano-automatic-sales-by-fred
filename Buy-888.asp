<% Option Explicit %><%

Const unitprice = "12"


Dim fsol
Set fsol = CreateObject("Scripting.FileSystemObject")

Function RndInt(Lower, Upper)
  Randomize Timer + 112
  RndInt = Int((Upper-Lower+1)*Rnd+Lower)
End Function
Function ReadTXTFile(strFile)
  Dim objTextFile, sReadAll
  Const ForReading = 1
  'Check if file exsists if not...
  Set objTextFile = fsol.OpenTextFile(strFile, ForReading)
  sReadAll = objTextFile.ReadAll
  'Cleanup objects.
  objTextFile.Close
  Set objTextFile = Nothing
  ReadTXTFile = sReadAll
End Function
Function WriteTXTFile(ByVal strFile, ByVal strTXT)
  Const ForWriting = 2
  Const ForAppending = 8
  Dim objTextFile
  'Set FSOl = Server.CreateObject("Scripting.FileSystemObject")
   If FSOl.FileExists(strFile) = True Then
  Set objTextFile = FSOl.OpenTextFile(strFile, ForAppending)
   Else
  Set objTextFile = FSOl.CreateTextFile(strFile, ForWriting)

   End If
      objTextFile.Write strTXT
      objTextFile.Close
  Set objTextFile = Nothing
End Function
Sub LocalLog(thisInfo)
  WriteTXTFile server.MapPath("logstep1.log"), Request.servervariables("remote_addr") & "   " & NOW & "   " & thisInfo & vbCrLf
End Sub



'Response.Redirect "PreSale1.asp"



Dim iCountSold: iCountSold = 0
Dim iCountBusy: iCountBusy = 0
Dim iCountReady: iCountReady = 0
Dim iCountJobs: iCountJobs = 0

If strcomp(Request.QueryString("Timeout"), "True") = 0 Then
LocalLog "-Request.QueryString(""Timeout"")-=-" & Request.QueryString("Timeout") & "-" & vbcrlf & vbcrlf
  Dim checkTimedOut
  if fsol.FileExists(Server.MapPath("ready/busy/" & replace(Session("tSlot"), ".work", ".busy"))) = True Then
    checkTimedOut = ReadTXTFile(Server.MapPath("ready/busy/" & replace(Session("tSlot"), ".work", ".busy")))  'If time expired, kill their session / sale slot.
    LocalLog "checkTimedOut=" & checkTimedOut & ", " & datediff("n", checkTimedOut, now) & " mins ago" & vbcrlf & vbcrlf
    if datediff("n", checkTimedOut, now) > 10 then
	LocalLog "Reset their slot on default due to checkTimeOut > 10 from inside the ready/busy/slot.busy file"
	  Session("tSlot") = "" 'Reset their slot if they show up here with a timeout message.
	  Session("tSlotTime") = ""
          Session("item") = ""
    end if
  else
    '? we have a session variable without an ip recorded? 
  end if
End If



Function CountWork() 
  dim newPath, child, folder, outList, iSold
  iSold = 0
  
  newPath = Server.MapPath("ready") 'folder named "ready" where we keep the work.
  set folder = fsol.GetFolder(newPath)
  For Each child In folder.Files
      'Only add the jobs where the extensions are .sold
      if instr(1, child.Name, ".sold") > 0 then
        iCountSold = iCountSold + 1
      end if
      if instr(1, child.Name, ".addr") > 0 then
        iCountJobs = iCountJobs - 1 'Remove this item
      end if
      if instr(1, child.Name, ".busy") > 0 then
        iCountBusy = iCountBusy + 1
        safeResetThisJobSlot child.Name
      end if
On Error Resume Next 'We put this here because after we delete the child.Name above any attempt to read this string seems to cause file not found.
'LocalLog "Debug: mol-CountWork->: process child.name: " & Child.Name & vbcrlf

      if instr(1, child.Name, ".work") > 0 then
        iCountReady = iCountReady + 1
      end if
      if len(child.Name) > 2 then
        iCountJobs = iCountJobs + 1
      end if

'LocalLog "Debug: eol-CountWork->: process child.name: " & Child.Name & vbcrlf

On Error Goto 0 'reset for next round.

  Next
  iCountJobs = iCountJobs - 3 'There are 3 worker files here that we need to ignore.
End Function


Sub safeResetThisJobSlot_session
' I am concerned and need to double-check this - does the tSlot contain .work in it and this routine is not removing that - oops the on error might have been masking the mistake.. needs to be tested.
'Dim fso
'On Error Resume Next

'In other areas we used this: >>>
'replace(yourSpot, ".work", ".busy")
'below we are not doing a similar thing, I bet it was failing here.

Dim thisSlotCleaned
thisSlotCleaned = replace(Session("tSlot"), ".work", "")

'Set fso = CreateObject("Scripting.FileSystemObject")
if fsol.FileExists(Server.MapPath(thisSlotCleaned & ".addr")) = True Then
LocalLog "-deletefile=-" & Server.MapPath(thisSlotCleaned & ".addr")
	fsol.DeleteFile(Server.MapPath(thisSlotCleaned & ".addr")) 'Delete the payout 
end if
if fsol.FileExists(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy")) = True Then
LocalLog "-ipbusyfile=-" & Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy")
	fsol.DeleteFile(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy"))
end if
if fsol.FileExists(Server.MapPath(thisSlotCleaned & ".busy")) = True Then
LocalLog "-slotbusyfile=-" & fsol.FileExists(Server.MapPath(thisSlotCleaned & ".busy"))
	fsol.MoveFile Server.MapPath(thisSlotCleaned & ".busy"), Server.MapPath(thisSlotCleaned & ".work")
end if
End Sub


Sub safeResetThisJobSlot(thisSlotCleaned)
LocalLog "-safeResetThisJobSlot----thisSlotCleaned=-" & thisSlotCleaned


'Also check for a .busy file without a .addr and reset it right away?

Dim newSlotInfo
newSlotInfo = Replace(thisSlotCleaned, ".busy", "")

'On Error Resume Next

  Dim checkTimedOut
LocalLog "Debug: -safeResetThisJobSlot->Check for this file: " & Server.MapPath("ready/busy/" & newSlotInfo & ".busy") & vbcrlf
  if fsol.FileExists(Server.MapPath("ready/busy/" & newSlotInfo & ".busy")) = True Then
    checkTimedOut = ReadTXTFile(Server.MapPath("ready/busy/" & newSlotInfo & ".busy"))  'If time expired, kill their session / sale slot.

LocalLog "Debug: -safeResetThisJobSlot->checkTimedOut contents=" & checkTimedOut & vbcrlf

    if datediff("n", checkTimedOut, now) > 10 then

LocalLog "Debug: -safeResetThisJobSlot->about to delete this:" & Server.MapPath("ready/busy/" & newSlotInfo & ".busy") & vbcrlf
      fsol.DeleteFile Server.MapPath("ready/busy/" & newSlotInfo & ".busy") 'clean up the expired busy files.

LocalLog "Debug: -safeResetThisJobSlot->check if .addr exists:" & Server.MapPath("ready/" & newSlotInfo & ".addr") & vbcrlf

      if fsol.FileExists(Server.MapPath("ready/" & newSlotInfo & ".addr")) = True Then
LocalLog "Debug: -safeResetThisJobSlot->deletefile=-" & Server.MapPath("ready/" & newSlotInfo & ".addr")
	fsol.DeleteFile(Server.MapPath("ready/" & newSlotInfo & ".addr")) 'Delete the payout
      end if

LocalLog "Debug: -safeResetThisJobSlot->check if .busy exists:" & Server.MapPath("ready/" & newSlotInfo & ".busy") & vbcrlf
      if fsol.FileExists(Server.MapPath("ready/" & newSlotInfo & ".busy")) = True Then
LocalLog "Debug: -safeResetThisJobSlot->RESET .busy into .work" & vbcrlf
	fsol.MoveFile Server.MapPath("ready/" & newSlotInfo & ".busy"), Server.MapPath("ready/" & newSlotInfo & ".work")
LocalLog "Debug: -safeResetThisJobSlot->after moved .busy into .work" & vbcrlf
      end if
    end if

  end if
LocalLog "Debug: -safeResetThisJobSlot->end of sub" & vbcrlf
End Sub


CountWork



Dim readyTime
if fsol.FileExists(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy")) = True Then
  readyTime = ReadTXTFile(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy"))
  'If time expired, kill their session / sale slot.
  if datediff("n", readyTime, now) > 10 then
    fsol.DeleteFile Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy") 'clean up the expired busy files.
    'Attempt to reset the old busy job but error to be safe.
    if len(Session("tSlot")) > 0 Then
      safeResetThisJobSlot_session 'Reset the busy job (slot) file first using this session.
  Session("tSlotTime") = ""
  Session("tSlot") = "" 'Invalidate this slot assignment.
  Session("item") = "" 'Reset which item they had. 
    End If
  else
    'Resume a sale here.
    response.Redirect "BuyStep2.asp?Message=SaleNotDone"
  end if
end if


%><!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.0.1/dist/darkly/bootstrap.css" integrity="sha256-ihe3pdCtDYvURoNHfn6lw+J7gRlvApUeAYAq9FwiKSA=" crossorigin="anonymous">
    <title>Buy Now</title>
<style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  font-family: 'Caveat Brush', cursive !important;
}
body {
background-color: #FFF;
}
.nav-link {
 font-size: 1.5rem !important;
 padding: 10px;
 margin: 15px;
}
.container {
  color: #333;
  margin: 0 auto;
  text-align: center;
}
.nav-item {
  margin-right: 0rem;
}
.bg-light {
background-color: rgba(255,255,255,0.15) !important;
}




#hero {
  height: 800px;
  overflow: hidden;
  position: relative;
}

#content {
  background-color: #F1E0C3;
  font-family: 'Caveat Brush', cursive !important;
}

.layer {
  background-position: bottom center;
  background-size: auto;
  background-repeat: no-repeat;
  width: 100%;
  height: 800px;
  position: fixed;
  z-index: -1;
}

#hero-mobile {
  display: none;
  background: url("/img/headerdesign.png") no-repeat center bottom/cover;
  height: 320px;
}

.first-section {
  padding: 50px 0 20px 0;
}

.text-header {
  font-family: 'Caveat Brush', cursive !important;
  text-align: center;
}

h1 {
  line-height: 120%;
  margin-bottom: 30px;
}

p {
  font-family: 'Caveat Brush', cursive !important;
  line-height: 150%;
}

#hero,
.layer {
  min-height: 800px;
}

.layer-bg {
  background-image: url("/img/layer7.png");
}

.layer-1 {
  background-image: url("/img/layer6.png");
  background-position: left bottom;
}

.layer-2 {
  background-image: url("/img/layer5.png");
}

.layer-3 {
  background-image: url("/img/layer4.png");
  background-position: right bottom;
}

.layer-4 {
  background-image: url("/img/layer3.png");
}

.layer-overlay {
  background-image: url("/img/layer2.png");
}

@media only screen and (max-width: 768px) {
  #hero {
    display: none;
  }

  #hero-mobile {
    display: block;
  }
}




</style>
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Caveat+Brush&display=swap" rel="stylesheet">

  </head>
  <body>


<div class="container">
  <!-- Content here -->

   <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-p34f1UUtsS3wqzfto5wAAmdvj+osOnFyQFpp4Ua3gs/ZVWx6oOypYoCJhGGScy+8" crossorigin="anonymous"></script>


<form method="post" action="BuyStep1.asp" novalidate>
<div class="pt-1 text-center">

  <div class="col mx-auto">



  <div class="row">
    <div class="col">
      <div class="col card rounded-circle m-1 shadow " style="background-color: rgba(84,131,39,0.75) !important; background-image: url(m.jpg);background-position: center; background-repeat: no-repeat;">
        <div>
  <h1 class="display-6 fw-bold m-4 pt-5">BadAss Heroes</h1>
    
        </div>
        <div class="col-sm">
          <div class="mb-3">
            <div class="card-body">
              <p class="card-text">Price:<span class="display-3"><%=unitprice%> ADA</span><br />
<% If cLng(iCountReady) > 0 Then %>Paste your wallet address below &amp; click Buy Now!<% end if %>
              </p>
            </div>
          </div>
        </div>
        <div class="d-grid gap-2 mb-3" id="buyID">


<% If cLng(iCountReady) > 0 Then %>

<div class="input-group mb-3 position-relative" style="width: 98%; margin: 0 auto;">
  <input type="text" class="form-control is-invalid shadow" placeholder="Receive Address" aria-label="Receive Address" aria-describedby="basic-addon2" id="PayouttAddr" name="PayouttAddr" oninput="if (this.value.length > 20 && this.value.length < 199) {this.className='form-control is-valid';document.getElementById('Bbtn').className='btn btn-success btn-lg px-4 rounded-circle shadow'}else{this.className='form-control is-invalid';document.getElementById('Bbtn').className='btn btn-warning btn-lg px-4 disabled rounded-circle shadow'}">
   <div class="valid-tooltip rounded-circle">Click the Buy Now button to proceed
   </div>
   <div class="invalid-tooltip rounded-circle">
      Enter your receive address
   </div>
</div>
<button type="button" class="btn btn-warning btn-lg m-4 px-4 disabled rounded-circle shadow " onclick="this.style.display='none';this.form.submit()" id="Bbtn" style="max-width: 220px; margin: 0 auto !important;">Click here to buy now</button>



<% end if %>




</div>
<div class="col-sm" style="max-width: 450px; margin: 0 auto;">


             <div class="card bg-light mb-3  rounded-circle">
                <div class="">Stats</div>
                <div class="card-body" style="padding: 2px; margin: 8px 75px;">
<p>
Total Available: <%=iCountJobs%><br />
Ready: <%=iCountReady%><br />
Busy: <%=iCountBusy%><br />
Sold: <%=iCountSold%><br />
                </div>
              </div>
    </div>
</div>


        </div>
      </div>
    </div>
  </div>




  </div>







</div>
</form>










</div>






<script language="javascript">
(function() {
 window.addEventListener('scroll', function(event) {
    var depth, i, layer, layers, len, movement, topDistance, translate3d;
    topDistance = this.pageYOffset;
    layers = document.querySelectorAll("[data-type='parallax']");
    for (i = 0, len = layers.length; i < len; i++) {
      layer = layers[i];
      depth = layer.getAttribute('data-depth');
      movement = -(topDistance * depth);
      translate3d = 'translate3d(0, ' + movement + 'px, 0)';
      layer.style['-webkit-transform'] = translate3d;
      layer.style['-moz-transform'] = translate3d;
      layer.style['-ms-transform'] = translate3d;
      layer.style['-o-transform'] = translate3d;
      layer.style.transform = translate3d;
    }
  });

}).call(this);




</script>





  </body>
</html>
<%
  set fsol = nothing
%>
