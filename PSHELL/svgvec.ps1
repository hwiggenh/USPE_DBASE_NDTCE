<# =======================================================================
 FILE:		 	svgvec.ps1 
 TYPE:			M$ powershell script
 PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
 PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
 USAGE:			SVGVEC ARR
 				ARR: interer array with amplitudes of vector
 DESCRIPTION:	creates svg plot file in file in temp directory
				lineplot of numbers over index

 USAGE:	 		SVGTestArea QR TAB
 				QR: object containing transducer positions
 				TAB: TestSeries, TestArea or USPEData
 DESCRIPTION: 	creates svg plot of TestArea 
 				positions of transducers are plotted for choosen selection
 				red circle: transmitter
 				blue disc: receiver

 OUTPUT:		svg plot file
 
 TODO:			include additional info in plot
 
 AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
 COPYRIGHT: 	none -- do whatever you want to do with this script 
 WARRANTY:		none -- absolutely no warranty - use at your own risk  
 REVISION:  	2022-08-23 initial draft 
======================================================================== #>

# creates svg plot file of integer array (lineplot number over index)

function SVGVEC([int[]]$ARR)
{

	$SVGFN = New-TemporaryFile						# temporary svg dump file

	$i=0;
	$MAX	= $ARR[0]								# max/min value in array for scaling plot
	$MIN	= $ARR[0]								# set max and min to first index value
	$PLINE	= "<polyline points='"   				# create polyline and find min/max in loop
	foreach ( $V in $ARR)							# loop through array
	{
		$PLINE+="$i,$V "
		$i++										# loop counter
		if ( $V -gt $MAX ) { $MAX=$V }				# find maximum of vector
		if ( $V -lt $MIN ) { $MIN=$V }				# find minimum of vector
	}
	if ( $MAX -lt [int][Math]::Abs($MIN) ) { $MAX =  [int][Math]::Abs($MIN) } # else { $MAX = $ARR.Maximum	}		# max of max and abs(min)

													# create SVG plot
	Add-Content $SVGFN  "<svg width='1200' height='1200'"
	Add-Content $SVGFN  " viewBox='-100 -600 1200 1200'"
	Add-Content $SVGFN  " xmlns='http://www.w3.org/2000/svg'>"
	Add-Content $SVGFN  "<rect x='-100' y='-600' width='100%' height='100%' fill='white'/>" 		# background color white
	Add-Content $SVGFN  "<rect x='0' y='-500' width='1000' height='1000' style='fill:lightgray;stroke:red;stroke-width:1' />" 

	Add-Content $SVGFN  $PLINE 	
					# add polyline to svg
													# mirror polyline on x-axis to display negative numbers below x-axis
													# and close svg 
													
							
	Add-Content $SVGFN  ("' style='fill:none;stroke:red;stroke-width:2' transform='scale(",(1000/$ARR.Length)," ",(-500/$MAX),")' /></svg>" -join " ") 

													# rename $SVGFN to have extension svg first secure Directory path
	$SVGPATH = (get-item $SVGFN).Directory
	Rename-Item -Path $SVGFN -NewName ($SVGFN.basename+".svg")

													# re-read renamed file
	$SVGFN = Get-Childitem -Path $SVGPATH ($SVGFN.basename+".svg")
 	Invoke-Item $SVGFN								# lauch viewer


}
#
# creates SVG plot of TestArea with position of selected transducers
#
function SVGTestArea([object[]]$QR,[string]$TAB) 
{


	$SVGFN = New-TemporaryFile											# temporary svg dump file

	# create SVG size 1200x1200 viewbox matches TestArea plus 100px margin

	Add-Content $SVGFN ("<svg style='stroke-width: 0px;background-color:white;' width=`"$($QR[0].SizeX+200)`" height=`"$($QR[0].SizeY+200)`" " )
	Add-Content $SVGFN (" viewBox='-100 -100 ", $($QR[0].SizeX+200), $($QR[0].SizeY+200),"'" -join " ") 
	Add-Content $SVGFN (" xmlns='http://www.w3.org/2000/svg'>")
	Add-Content $SVGFN ('<rect x="-100" y="-100" width="100%" height="100%" fill="white"/>' )			# background color white
	Add-Content $SVGFN ("<rect width='", $QR[0].SizeX,"' height='", $QR[0].SizeY,"' style='fill:lightgray;stroke-width:0;' />" -join " " )	 
	Add-Content $SVGFN ('<circle r="10" style="fill:black;stroke-width:0;" />' )						# zero marker


																		# plot map as dotted white lines if TS or US is called
																		# TA may show positions of tests collected in different 
																		# maps and therefore not drawn
	if ( $TAB -ne "TA" ) { 

		$style = "stroke:white;stroke-width:1;stroke-dasharray:2,2"
		for ( [int]$X = [int]$QR[0].X0; [int]$X -lt [int]$QR[0].SizeX; [int]$X =  [int]$X + [int]$QR[0].XD) 
		{
			Add-Content $SVGFN ( "<line x1='", $X, "' y1='",$QR[0].Y0,"' x2='",$X,"' y2='", $QR[0].SizeY,"' style='",$style,"' />" -join " ")
		}
		for ( [int]$Y = [int]$QR[0].Y0; [int]$Y -lt [int]$QR[0].SizeY; [int]$Y = [int]$Y + [int]$QR[0].YD)
		{
			Add-Content $SVGFN ("<line x1='", $QR[0].X0,"' y1='",$Y,"' x2='",$QR[0].SizeX,"' y2='", $Y,"' style='",$style,"' />" -join " ")
		}
	}
																		# plot sensor positions, transmitter red circle receiver blue disc
	$i = 0
	while ($i -lt $QR.length){

		Add-Content $SVGFN ("<circle cx='",$QR[$i].TX,"' cy='",$QR[$i].TY,"' r='12' style='fill:none;stroke-width:3;stroke:red' />" -join " ")
		Add-Content $SVGFN ("<circle cx='",$QR[$i].RX, "' cy='",$QR[$i].RY, "' r='10' style='fill:blue;stroke-width:0;' />" -join " " )
	   	$i++
	}

	Add-Content $SVGFN '</svg>' 												# close svg
	

	# rename $SVGFN to have extension svg first secure Directory path
	$SVGPATH = (get-item $SVGFN).Directory
	Rename-Item -Path $SVGFN -NewName ($SVGFN.basename+".svg")

	# re-read renamed file
	$SVGFN = Get-Childitem -Path $SVGPATH ($SVGFN.basename+".svg")
 	$nix = Invoke-Item $SVGFN

}

