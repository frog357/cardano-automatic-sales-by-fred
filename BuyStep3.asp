<% Option Explicit %><%
Function RndInt(Lower, Upper)
  Randomize Timer + 372
  RndInt = Int((Upper-Lower+1)*Rnd+Lower)
End Function
Function ReadTXTFile(strFile)
  WriteTXTFile Server.MapPath("ReadLog.txt"), strFile & vbcrlf
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
   If objFSO.FileExists(strFile) <> True Then
  Set objTextFile = objFSO.CreateTextFile(strFile, ForWriting)
   Else
  Set objTextFile = objFSO.OpenTextFile(strFile, ForAppending)
   End If
      objTextFile.Write strTXT
      objTextFile.Close
  Set objTextFile = Nothing
  Set objFSO = Nothing
End Function

Sub LocalLog(thisInfo)
  WriteTXTFile server.MapPath("logstep3.log"), Request.servervariables("remote_addr") & "   " & NOW & "   " & thisInfo & vbCrLf
End Sub

Function ListFolder(path) 
  Dim fs, newPath, child, folder, outList
  Set fs   = CreateObject("Scripting.FileSystemObject")
  newPath = Server.MapPath(path)
  set folder = fs.GetFolder(newPath)
  For Each child In folder.Files
      'Only add the jobs where the extensions are .work not .busy
      if instr(1, child.Name, ".work") > 0 then
        outList = outList & child.Name & vbcrlf
      end if
  Next
  Set fs = Nothing
  ListFolder = outList
End Function




Dim fso, tellWhich, wasItem
Set fso = CreateObject("Scripting.FileSystemObject")
 'ONLY INVALIDATE HERE IF WE SOLD!

if fso.FileExists(Server.MapPath("ready/" & replace(Session("tSlot"), ".work", ".sold"))) = True Then
  tellWhich = Replace(Session("tSlot"), ".work", "")
  wasItem = Session("item")

  Session("tSlotTime") = ""
  Session("tSlot") = "" 'Invalidate this slot assignment.
  Session("item") = "" 'Reset which item they had.


  if fso.FileExists(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy")) = True Then
    fso.DeleteFile(Server.MapPath("ips/" & Request.ServerVariables("remote_addr") & ".busy"))
  end if
else

  response.redirect "buy-888.asp"

end if 'Only if we found the .sold item.

set fso = Nothing


%><!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.0.0/dist/lux/bootstrap.min.css" integrity="sha256-X/gLsEBvXlVXphf1+kuY98azm27+Y2zbELaVNQBsEQs=" crossorigin="anonymous">

    <title>Sale Completed!</title>
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
.message {
  font-size: 2rem;
  display: none;
  padding: 1rem;
}
.nav-item {
  margin-right: 0rem;
}
.bg-light {
background-color: rgba(255,255,255,0.75) !important;
}
.contain{
	position:absolute;
	top:10px;
	left:0;
	width:100%;
	height:100%;
	z-index: -1;
}

.done{
	width:100px;
	height:100px;
	position:relative;
	left: 0;
	right: 0;
	top:-10px;
	margin:auto;
}
.contain h1{
	font-family: 'Julius Sans One', sans-serif;
	font-size:1.4em;
	color: #000;
}

.congrats{
	position:relative;
	left:50%;
	top:40%;
	max-width:800px;	transform:translate(-50%,-50%);
	width:80%;
	min-height:300px;
	max-height:900px;
	border:2px solid white;
	border-radius:5px;
	    box-shadow: 12px 15px 20px 0 rgba(46,61,73,.3);
    background-image: linear-gradient(to bottom right,#02b3e4,#02ccba);
	background:#fff;
	text-align:center;
	font-size:2em;
	color: #189086;
}

.text{
	position:relative;
	font-weight:normal;
	left:0;
	right:0;
	margin:auto;
	width:80%;
	max-width:800px;

	font-family: 'Lato', sans-serif;
	font-size:0.6em;

}


.circ{
    opacity: 0;
    stroke-dasharray: 130;
    stroke-dashoffset: 130;
    -webkit-transition: all 1s;
    -moz-transition: all 1s;
    -ms-transition: all 1s;
    -o-transition: all 1s;
    transition: all 1s;
}
.tick{
    stroke-dasharray: 50;
    stroke-dashoffset: 50;
    -webkit-transition: stroke-dashoffset 1s 0.5s ease-out;
    -moz-transition: stroke-dashoffset 1s 0.5s ease-out;
    -ms-transition: stroke-dashoffset 1s 0.5s ease-out;
    -o-transition: stroke-dashoffset 1s 0.5s ease-out;
    transition: stroke-dashoffset 1s 0.5s ease-out;
}
.drawn svg .path{
    opacity: 1;
    stroke-dashoffset: 0;
}

.regards{
	font-size:.7em;
}


@media (max-width:600px){
	.congrats h1{
		font-size:1.2em;
	}
	
	.done{
		top:-10px;
		width:80px;
		height:80px;
	}
	.text{
		font-size:0.5em;
	}
	.regards{
		font-size:0.6em;
	}
}

@media (max-width:500px){
	.congrats h1{
		font-size:1em;
	}
	
	.done{
		top:-10px;
		width:70px;
		height:70px;
	}
	
}

@media (max-width:410px){
	.congrats h1{
		font-size:1em;
	}
	
	.congrats .hide{
		display:none;
	}
	
	.congrats{
		width:100%;
	}
	
	.done{
		top:-10px;
		width:50px;
		height:50px;
	}
	.regards{
		font-size:0.55em;
	}
	
}
</style>
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Caveat+Brush&display=swap" rel="stylesheet">

  </head>
  <body>

<div class="contain">
	<div class="congrats">
		<h1>Congrat<span class="hide">ulation</span>s !</h1>
		<div class="done">
			<svg version="1.1" id="tick" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 37 37" style="enable-background:new 0 0 37 37;" xml:space="preserve">
<path class="circ path" style="fill:#0cdcc7;stroke:#07a796;stroke-width:3;stroke-linejoin:round;stroke-miterlimit:10;" d="
	M30.5,6.5L30.5,6.5c6.6,6.6,6.6,17.4,0,24l0,0c-6.6,6.6-17.4,6.6-24,0l0,0c-6.6-6.6-6.6-17.4,0-24l0,0C13.1-0.2,23.9-0.2,30.5,6.5z"
	/>
<polyline class="tick path" style="fill:none;stroke:#fff;stroke-width:3;stroke-linejoin:round;stroke-miterlimit:10;" points="
	11.6,20 15.9,24.2 26.4,13.8 "/>
</svg>
			</div>
		<div class="text">
		<p>Your purchase is complete!<br />
<%



Response.Write "<img src=""/sale2img/" & tellWhich & ".png" & Chr(34) & " class=""img-fluid""><br />"
%>
		</p>
			<p><a href="Buy-888.asp">Click here to buy again!</a>
			</p>
			</div>
		<p class="regards">Thank You - We hope you enjoy!</p>
	</div>
</div>




   <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-p34f1UUtsS3wqzfto5wAAmdvj+osOnFyQFpp4Ua3gs/ZVWx6oOypYoCJhGGScy+8" crossorigin="anonymous"></script>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
<script language="javascript">
$(window).on("load",function(){
	setTimeout(function(){$('.done').addClass("drawn");},500)
});
</script>
  </body>
</html>
