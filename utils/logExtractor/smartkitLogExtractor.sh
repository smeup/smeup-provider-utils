#!/bin/bash

##########################
#  GLOBAL LOG EXTRACTOR  #
##########################

# Month from number to String
extractMonth() {
    case "$1" in
        01)  
            echo "Gen" 
            ;;
        02)  
            echo "Feb" 
            ;;
        03)  
            echo "Mar" 
            ;;
        04)  
            echo "Apr" 
            ;;
        05)  
            echo "Mag" 
            ;;
        06)  
            echo "Giu" 
            ;;
        07)  
            echo "Lug" 
            ;;
        08)  
            echo "Ago" 
            ;;
        09)
            echo "Set" 
            ;;
        10) 
            echo "Ott" 
            ;;
        11)  
            echo "Nov" 
            ;;
        12)  
            echo "Dec" 
            ;;
esac
}

# Extract info from input data
extractData(){
    #echo "[DEBUG] input: $1"
    
    IFS='/' read -ra ADDR <<< "$1"

    DD=${ADDR[0]}
    MM=${ADDR[1]}
    YYYY=${ADDR[2]}

    MESE=$(extractMonth "$MM")

}

extractAllRequestCalls(){
    if [[ $1 == "-s" ]];
    then
        # Extract the only JA_00_52 call
        grep -rw 'Wait=300	F(XML;JA_00_52;SND.PAY)' ./solo_$DD$MM$YYYY.log | awk '{out=$4; for(i=14;i<=NF;i++){out=out" "$i}; print out}' > allReq_$2_$DD$MM$YYYY.log
    else
        # Extract the only JA_31_00 call
        grep -rw 'ESTCPRVKIT FUN: F(XML;JA_31_00' ./solo_$DD$MM$YYYY.log | awk '{out=$4; for(i=14;i<=NF;i++){out=out" "$i}; print out}' > allReq_$2_$DD$MM$YYYY.log
    fi
    
}

# Extract the only Error's call
extractAllErrorCalls(){
    if [[ $1 == "-s" ]];
    then
        grep -rw 'Status: \*ERROR' ./solo_$DD$MM$YYYY.log | awk '{out=$4; for(i=14;i<=NF;i++){out=out"   "$i}; print out}' > allErrReq_$2_$DD$MM$YYYY.log
    else
        grep -rw 'MESSAGGIO PER STAMPA STACK TRACE EXCEPTION' ./solo_$DD$MM$YYYY.log | awk '{out=$4; for(i=14;i<=NF;i++){out=out"   "$i}; print out}' > allErrReq_$2_$DD$MM$YYYY.log
    fi
}

# Extract the call and the Errors
extractCallsAndErrors(){
    if [[ $1 == "-s" ]];
    then
        # Error with status code
        egrep "(Wait=300	F\(XML;JA_00_52;SND.PAY\)|Status: \*ERROR|Value:)" ./solo_$DD$MM$YYYY.log | awk '{out=$4; for(i=15;i<=NF;i++){out=out"   "$i}; print out}' > allReqWithError_$2_$DD$MM$YYYY.log
    else
        # Error if is exception
        egrep -i "ESTCPRVKIT FUN: F\(XML;JA_31_00|EXCEPTION" ./solo_$DD$MM$YYYY.log | awk '{out=$4; 
        if( $15 == "" ) 
            for(i=12;i<=NF;i++)
            {out=out"   "$i}
        else 
            for(i=17;i<=NF;i++)
            {out=out"   "$i}; 
        
        print out
            }' > allReqWithError_$2_$DD$MM$YYYY.log
    fi
}

# Extract each single call type
extractAllCallsType(){
    if [[ $1 == "-s" ]];
    then
        extractSingleTypeCalls "4\(;;AUTH\)" "AUTH_"
        extractSingleTypeCalls "4\(;;FIFR\)" "FIFR_"
        extractSingleTypeCalls "4\(;;RIFR\)" "RIFR_"
        extractSingleTypeCalls "4\(;;UPLOADFATTURA\)" "UPLOAD_"
    else
        extractSingleTypeCalls "F\(XML;JA_31_00;AUTH\)" "AUTH_"
        extractSingleTypeCalls "F\(XML;JA_31_00;FIFR\)" "FIFR_"
        extractSingleTypeCalls "F\(XML;JA_31_00;RIFR\)" "RIFR_"
        extractSingleTypeCalls "F\(XML;JA_31_00;UPLOADFATTURA\)" "UPLOAD_"
    fi
    
}

extractSingleTypeCalls(){
    egrep "$1" allReqWithError_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log > ./call_$CALL_SERVICE_NAME/"$2"$DD$MM$YYYY.log
}

# Read all rows and count it
countFileRow(){
    NUM_ROW=0 
        
    #echo "[DEBUG] FILE: $1"
    while IFS= read -r line
    do
        NUM_ROW=$((NUM_ROW+1))
    done < $1

    echo "$NUM_ROW"
}

# Calc human-time from 2 times
calcTime(){
    local T1=$(date --date "$YYYY-$MM-$DD $1" +%s%3N)
    local T2=$(date --date "$YYYY-$MM-$DD $2" +%s%3N)
    local DELTA=$((T2-T1))

    if [[ $((DELTA/(60*60*1000))) -gt 0 ]]; # Hour
    then
        echo "$(echo "scale=2;${DELTA}/3600000" | bc | tr '.' ',') h" 
    else
        if [[ $((DELTA/(60*1000))) -gt 0 ]]; # Minutes
        then 
            echo "$(echo "scale=2;${DELTA}/60000" | bc | tr '.' ',') m"
        else
            if [[ $((DELTA/1000)) -gt 0 ]]; # Seconds
            then 
                echo "$(echo "scale=2;${DELTA}/1000" | bc | tr '.' ',') s"
            else # Milliseconds
                echo "$DELTA ms"
            fi
        fi
    fi
}




### INIZIO PGM

if [[ "$#" -lt 2 || "$#" -gt 3 ]];
then
     echo "Illegal number of parameters"
     echo "Must be: \"script.sh <SmartkitType> GG/MM/YYYY\""
     exit -1
fi

# TODO - Increase stability from input parameters
if [ "$#" -eq 2 ]; 
then
    TYPE=$1

    extractData "$2"

    FILE_COUNT=`ls -1 *.LOG* 2>/dev/null | wc -l`
    if [[ $FILE_COUNT -eq 0  ]];
    then
        echo "No log file found in folder"
        exit -1
    fi
    
    # Extract from all logs only the field that contains the specified data
    grep -rw "$DD $MESE $YYYY" ./*.LOG* > solo_$DD$MM$YYYY.log

    if [[ ! -s solo_$DD$MM$YYYY.log ]];
    then
        echo "No results with input parameters!"
        echo "Possible wrong date!"
        exit -1
    fi

    # If is Smeup or NotSmeup log file
    if [[ $TYPE == "-s" ]];
    then
        echo " --- SMEUP VERSION --- "
        CALL_SERVICE_NAME="JA_00_52"
    else
        echo " --- NO-SMEUP VERSION --- "
        CALL_SERVICE_NAME="JA_31_00"
    fi

    # Create call folder if there isn't
    if [ ! -d "./call_$CALL_SERVICE_NAME" ];
    then
        mkdir ./call_$CALL_SERVICE_NAME
    fi

    extractAllRequestCalls $TYPE $CALL_SERVICE_NAME
    extractAllErrorCalls $TYPE $CALL_SERVICE_NAME
    extractCallsAndErrors $TYPE $CALL_SERVICE_NAME
    extractAllCallsType $TYPE $CALL_SERVICE_NAME

    NUM_CALL=$(countFileRow "allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log")
    echo -e "Number of Calls:\t $NUM_CALL"
    
    if [[ $NUM_CALL -gt 0 ]];
    then
        ORARIO_INIZIO=$(sed '1q;d' allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log | awk {'print $1}')
        ORARIO_FINE=$(sed '$q;d' allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log | awk {'print $1}')
        echo -e "Start time:\t $ORARIO_INIZIO"
        echo -e "Stop time:\t $ORARIO_FINE"

        TIME=$(calcTime $ORARIO_INIZIO $ORARIO_FINE)
        echo -e "Elapsed time:\t $TIME"
        
        ## .. avg call interval calculation
        I=0
        T1=0
        T2=0
        SUM_MS=0
        SUM_SEC=0
        echo "" > ./call_$CALL_SERVICE_NAME/deltaCall.log
        while IFS= read -r line
        do
            I=$((I+1))
            T_1=$(sed "$I q;d" allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log | awk {'print $1}')
            #echo "[DEBUG] T_1: $T_1"
            I2=$((I+1))
            T_2=$(sed "$I2 q;d" allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log | awk {'print $1}')
            #echo "[DEBUG] T_2: $T_2"

            # TODO - Extract function
            if [ ! -z "$T_2" ];then
                TIME_T_1=$(date --date "$YYYY-$MM-$DD $T_1" +%s%3N)
                TIME_T_2=$(date --date "$YYYY-$MM-$DD $T_2" +%s%3N)
                #echo "[DEBUG] TIME_T_1: $TIME_T_1"
                #echo "[DEBUG] TIME_T_2: $TIME_T_2"
                DELTA_MS=$((TIME_T_2 - TIME_T_1))
                DELTA_SEC=$(echo "scale=2;${DELTA_MS}/1000" | bc)
                #echo "[DEBUG] DELTA_parziale: $DELTA_MS ms"
                SUM_MS=$((SUM_MS + DELTA_MS))
                #echo "[DEBUG] SOMMA_parziale: $SUM_MS ms"
                echo -e "$T_1  -  $T_2 -->\t[$DELTA_MS] ms --->\t[$DELTA_SEC] s" >> ./call_$CALL_SERVICE_NAME/deltaCall.log
            fi
            
        done < allReq_"$CALL_SERVICE_NAME"_$DD$MM$YYYY.log
        
        #echo "[DEBUG] SOMMA: $SUM_MS"
        MEDIA_MS=$((SUM_MS / NUM_CALL))
        MEDIA_SEC=$(echo "scale=2;${MEDIA_MS}/1000" | bc)
        echo -e "Avg time between calls:\t $MEDIA_MS ms --->\t $MEDIA_SEC s"
    else
        echo "No results with input parameters!"
        echo "Possible wrong <SmeupType> or wrong date!"
    fi
fi

exit 0
