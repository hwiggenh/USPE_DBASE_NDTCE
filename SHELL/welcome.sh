# =======================================================================
# FILE:		 	welcome.ps1 
# TYPE:			M$ powershell script
# PROJECT:		Minimal database for Ultrasound Pulse Echo data https://github.com/hwiggenh/USPE_DBASE_NDTCE
# PREREQUISITS:	power shell, mysql installation with database USPE installed, DBDATA directory
# USAGE:			<path to file>/welcome.ps1 
# 				needs DBDATA and SQLConnectString set to local values
#
# DESCRIPTION:	shell script opens dialog to basic database actions
#				
# OUTPUT:		none
# 
# TODO:			add more actions
# 
# AUTHOR:	 	Herbert Wiggenhauser https://github.com/hwiggenh
# COPYRIGHT: 	none -- do whatever you want to do with this script 
# WARRANTY:		none -- absolutely no warranty - use at your own risk  
# REVISION:  	2022-08-23 initial draft 
# ========================================================================
export LC_ALL=C    												# make sure we aren't in a multibyte locale

# set environment
source ./USPE_ENV.sh

PS3='Welcome, what would you like to do, please enter your choice: '

options=("Quit" "Create TestSeries" "Create TestArea" "Create TestEquipment" "Upload A1220 tests" "Upload A1040-MIRA tests" "Display AScan (USData.ID needed)" "Display TestArea (TestArea.ID needed)" "Display Testseries (TestSeries.ID needed)" "Display USData on TestArea (USPEData.ID needed)")
select opt in "${options[@]}"
do
    case $opt in
        "Quit")
            break
            ;; 
         "Create TestSeries") 
            echo "you chose: Create TestSeries"
			source ./CreateNewTestSeries.sh
            ;;
         "Create TestArea") 
            echo "you chose: $opt"
			source ./CreateNewTestArea.sh
            ;;
         "Create TestEquipment") 
             echo "you chose: $opt"
			source ./CreateNewTestEquipment.sh
            ;;
         "Upload A1220 tests" )
            echo "you chose: $opt"
			read -p 'TestArea.ID Default=1 ?> ' ChoTA
			[[ $ChoTA =~ ^[0-9]+$ ]] || { echo "not an integer"; ChoTA=1; }
			read -p 'TestSeries.ID Default=1 ?> ' ChoTS
			[[ $ChoTS =~ ^[0-9]+$ ]] || { echo "not an integer"; ChoTS=1; }
			source ./UploadA1220.sh $ChoTA $ChoTS	
            ;;
         "Upload A1040-MIRA tests") 
            echo "you chose: $opt"
			read -p 'TestArea.ID Default=1 ?> ' ChoTA
			[[ $ChoTA =~ ^[0-9]+$ ]] || { echo "not an integer"; ChoTA=1; }
			read -p 'TestSeries.ID Default=1 ?> ' ChoTS
			[[ $ChoTS =~ ^[0-9]+$ ]] || { echo "not an integer"; ChoTS=1; }
			source ./UploadMIRA.sh $ChoTA $ChoTS	
            ;;
         "Display AScan (USData.ID needed)") 
            echo "you chose: $opt"
 			read -p 'USPEData.ID Default=1 ?> ' Cho
			[[ $Cho =~ ^[0-9]+$ ]] || { echo "not an integer"; Cho=1; }
			source ./ReadAScan.sh $Cho ""
           ;;
         "Display TestArea (TestArea.ID needed)") 
            echo "you chose: $opt"
			read -p 'TestArea.ID Default=1 ?> ' Cho
			[[ $Cho =~ ^[0-9]+$ ]] || { echo "not an integer"; Cho=1; }
			source ./GetAndShowTestPosition.sh $Cho "TA"
            ;;
         "Display Testseries (TestSeries.ID needed)")
            echo "you chose: $opt"
			read -p 'TestSeries.ID Default=1 ?> ' Cho
			[[ $Cho =~ ^[0-9]+$ ]] || { echo "not an integer"; Cho=1; }
			source ./GetAndShowTestPosition.sh $Cho "TS"
            ;;
         "Display USData on TestArea (USPEData.ID needed)")
            echo "you chose: $opt"
			read -p 'USPEData.ID Default=1 ?> ' Cho
			[[ $Cho =~ ^[0-9]+$ ]] || { echo "not an integer"; Cho=1; }
			echo "CHO: "$Cho
			source ./GetAndShowTestPosition.sh $Cho "US"
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

