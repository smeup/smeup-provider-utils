# Smartkit Log Extractor

The following tool was created to allow the extraction and easy consultation of the GLOBAL log files issued by the smartkit

## How to

The few step to use the tool are:

- Clone this project
  
  ```bash
  mkdir gitFolder
  cd gitFolder
  git clone https://github.com/smeup/smeup-provider-utils.git
  ```

- Put the file *smartkitLogExtractor.sh* in a folder
  
  ```bash
  # Create a working folder
  mkdir wrkFolder
  cp gitFolder/utils/logExtractor/smartkitExtractor.sh /wrkFolder 
  ```

- Go in the specific working folder  and make .sh file executable
  
  ```bash
  cd wrkFolder
  chmod +x smartkitExtractor.sh
  ```

- Copy in current folder the smartkit GLOBAL .LOG file that we want to inspect
  
  ```bash
  # IMPORTANT! The log MUST BE one GLOBAL log file!!
  cp smartkitLog/GLOBAL/SMARTKIT-FE.LOG /wrkFolder
  ```

- Run tool
  
  ```bash
  # sh smartkitExtractor.sh <smeupType> <dateExtraction>
  sh smartkitExtractor.sh -s 01/01/2020
  
  # IMPORTANT the <smeupType> and <dateExtraction> must be not null
  # IMPORTANT the <dateExtraction> must be DD/MM/YYY
  
  ```
  
  - The ***<smeupType>*** is a parameter that can take 2 different values
    
    - **-s** : is used to indicate that the log file is a log of SMEUP smartkit
    
    - **-n** : is used to indicate that the log file is a log of NO-SMEUP smartkit
  
  - The <dateExtraction> is a parameter to indicate the date that we want to extract the calls.



## Result

The result of the tool's execution are the statistics below and a creation of a specific folder-tree:

```bash
# Result example
sh smartkitExtractor.sh -s 01/01/2020
 --- NO-SMEUP VERSION --- 
Number of Calls:	 457
Start time:	 12:27:44,183
Stop time:	 14:33:34,463
Elapsed time:	 2,09 h
Avg time between calls:	 16521 ms --->	 16.52 s
```

```bash
# LEGEND
# <smeupServiceCall> : the specific service of call (JA_00_52 or JA_31_00)
# <dateExtraction> : is the date that is choosed to extract (DDMMYYY) 
wrkFolder
|_ allErrReq_<smeupServiceCall>_<dateExtraction>.log
|_ allReq_<smeupServiceCall>_<dateExtraction>.log
|_ allReqWithError_<smeupServiceCal<dateExtraction>.log
|_ solo_<dateExtraction>.log
|_ call_<smeupServiceCall>
    |_ AUTH_<dateExtraction>.log
    |_ FIFR_<dateExtraction>.log
    |_ RIFR_<dateExtraction>.log
    |_ UPLOAD_&lt;dateExtraction&gt;.log
    |_ deltaCall.log

```

- **allErrReq...** : contains all the chronological failed-request to Abletech

- **allReq...** : contains all the chronological request to Abletech

- **allReqWithError...** : contains all the chronological request to Abletech with the respective failed-request (with the error type)

- **solo...** :  contains all the chronological request that satisfy the input date

- **AUTH** : contains only the authorization call

- **FIFR** : contains only the FIFR call

- **RIFR** : contains only the RIFR call

- **UPLOAD** : contains only the upload call

- **deltaCall** : contains information of the 












