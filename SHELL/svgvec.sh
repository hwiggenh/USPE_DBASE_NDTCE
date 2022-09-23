# =======================================================================
# FILE:		 	svgvec.ps1 
# TYPE:			M$ powershell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:		SVGVEC ARR
# 				ARR: interer array with amplitudes of vector
# DESCRIPTION:	creates svg plot file in file in temp directory
#				lineplot of numbers over index
#
# USAGE:	 	SVGTestArea QR TAB
# 				QR: object containing transducer positions
# 				TAB: TestSeries, TestArea or USPEData
# DESCRIPTION: 	creates svg plot of TestArea 
# 				positions of transducers are plotted for choosen selection
# 				red circle: transmitter
# 				blue disc: receiver
#
# OUTPUT:		svg plot file
# 
# TODO:			include additional info in plot
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
# FILE:		 	ReadMIRAVec.sh
# AUTHOR:	 	Herbert Wiggenhauser
# USAGE:		file should be sourced in calling shell script; ARR holds vector integers
# COPYRIGHT: 	None - do with it whatever you want to do
# REVISION:  	2022-08-23 initial draft 
# 
# Shell script creates very simple SVG plot of integer array ARR in temporaray file and opens viewer to display
# Ascan is scaled to fit in rectangle of 1000px x 1000 px with a 100px wide margin area
# SVG is saved to temporary file and registered viewer is launched 
#
source ./USPE_ENV.sh

function SVGVEC {
SVGFN=$(mktemp) 								# temporary svg dump file

i=0;
MAX=${ARR[0]}									# max/min value in array for scaling plot
MIN=${ARR[0]}									# set max and min to first index value
PLINE='<polyline points="'   					# create polyline and find min/max in loop
for V in ${ARR[@]};								# loop through array
do
	PLINE+="${i},$(( $V )) "
	i=$(( $i+1 ))								# loop counter
	[[ $V -gt $MAX ]] && MAX=$V;				# find maximum of vector
	[[ $V -lt $MIN ]] && MIN=$V;				# find minimum of vector
done
[[ $MAX -lt ${MIN#-} ]] && MAX=${MIN#-}			# max of max and abs(min)

												# create SVG plot
echo '<svg width="1200" height="1200"' > $SVGFN
echo ' viewBox="-100 -600 1200 1200"'>> $SVGFN
echo ' xmlns="http://www.w3.org/2000/svg">' >> $SVGFN
echo '<rect x="-100" y="-600" width="100%" height="100%" fill="white"/>' >> $SVGFN 		# background color white
echo '<rect x="0" y="-500" width="1000" 
		height="1000" style="fill:lightgray;stroke:red;stroke-width:1" />' >> $SVGFN

echo $PLINE >>  $SVGFN							# add polyline to svg
												# mirror polyline on x-axis to display negative numbers below x-axis
												# and close svg 
echo -n '" style="fill:none;stroke:red;stroke-width:2" 
			transform="scale('$(bc -l <<< "1000/${#ARR[@]}")' '$(bc -l <<< "-500/$MAX")')" /></svg>'  >> $SVGFN


mv $SVGFN "${SVGFN}.svg" 						# rename $SVGFN to have extension svg
# echo SVGPlot in "${SVGFN}.svg"

xdg-open "${SVGFN}.svg"							# opens default viewer for file

}
#
# plots TestArea 
#
function SVGTestArea() {

local arr=(${1// / }); 							# split query return at spaces
local TAB=${2:-TA}

SVGFN=$(mktemp) 								# temporary svg dump file

# create SVG size matches TestArea
echo '<svg style="stroke-width: 0px;background-color:white;" width="'$((${arr[5]}+200))'" height="'$((${arr[6]}+200))'"' > $SVGFN
echo ' viewBox="-100 -100 ' $((${arr[5]}+200)) $((${arr[6]}+200))'"'>> $SVGFN
echo ' xmlns="http://www.w3.org/2000/svg">' >> $SVGFN
echo '<rect x="-100" y="-100" width="100%" height="100%" fill="white"/>'>> $SVGFN 			# background color white
echo '<rect width="'${arr[5]}'" height="'${arr[6]}'" 
			style="fill:lightgray;stroke-width:0;" />' >> $SVGFN							# outline testArea
echo '<circle r="10" style="fill:black;stroke-width:0;" />' >> $SVGFN 						# zero marker

												# plot map as dotted white lines if TS or US is called
												# TA may show positions of tests collected in different 
												# map definitions 
if [[ $TAB != "TA" ]] 
then
	style="stroke:white;stroke-width:1;stroke-dasharray:2,2"
	for (( X=${arr[7]};X<${arr[5]};X=X+${arr[9]} ))
	do
		echo '<line x1="'$X'" y1="'${arr[8]}'" x2="'$X'" y2="'${arr[6]}'" style="'$style'" />' >> $SVGFN
	done
	for (( Y=${arr[8]};Y<${arr[6]};Y=Y+${arr[10]} ))
	do
		echo '<line x1="'${arr[7]}'" y1="'$Y'" x2="'${arr[5]}'" y2="'$Y'" style="'$style'" />' >> $SVGFN
	done
fi

												# plot sensor positions, transmitter red circle receiver blue dot
len=${#arr[@]};
for ((i=1;i<$len;i=i+11))
do
	echo '<circle cx="'${arr[$i]}'" cy="'${arr[$(($i+1))]}'" r="12" style="fill:none;stroke-width:3;stroke:red" />' >> $SVGFN 
	echo '<circle cx="'${arr[$(($i+2))]}'" cy="'${arr[$(($i+3))]}'" r="10" style="fill:blue;stroke-width:0;" />' >> $SVGFN 
done


echo -n '</svg>'  >> $SVGFN

# rename $SVGFN to have extension svg
mv $SVGFN "${SVGFN}.svg" 
# echo SVGPlot in "${SVGFN}.svg"

xdg-open "${SVGFN}.svg"			# opens default viewer for file
}

