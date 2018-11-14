; #VARIABLES/INCLUDES# ==================================================================
#include-once
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <InetConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GuiMenu.au3>
#include "_WinHttp.au3"
#include "_GraphGDIPlus.au3"

#Region MISC Function
; #FUNCTION# ===================================================================================================
; Name...........: _Unzip
; Description ...: Unzip with 7za
; Syntax.........: _Unzip($iPathZip , $iPathTarget)
; Parameters ....: $iPathZip	- Zip Path
;~ 				   $iPathTarget	- Target folder path
; Return values .: Success      - Return the target folder path
;                  Failure      - -1
; Author ........: Screech inspiration : wakillon
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; https://www.autoitscript.com/forum/topic/122168-tinypicsharer-v-1034-new-version-08-june-2013/
Func _Unzip($iPathZip, $iPathTarget)
	Local $sRun, $iPid, $_StderrRead
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPathZip, $sDrive, $sDir, $sFileName, $iExtension)
	If StringLower($iExtension) <> ".zip" Then
		_LOG("Not a ZIP file : " & $iPathZip, 2, $iLOGPath)
		Return -1
	EndIf
	$sRun = '"' & $iScriptPath & '\Ressources\7za.exe" x "' & $iPathZip & '" -o"' & $iPathTarget & '" -aoa'
	_LOG("7za command: " & $sRun, 1, $iLOGPath)
	$iPid = Run($sRun, '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	While ProcessExists($iPid)
		$_StderrRead = StderrRead($iPid)
		If Not @error And $_StderrRead <> '' Then
			If StringInStr($_StderrRead, 'ERRORS') And Not StringInStr($_StderrRead, 'Everything is Ok') Then
				_LOG("Error while unziping " & $iPathZip, 2, $iLOGPath)
				Return -2
			EndIf
		EndIf
	WEnd
	_LOG("Unziped : " & $iPathZip & " to " & $iPathTarget, 0, $iLOGPath)
	Return $iPathTarget
EndFunc   ;==>_Unzip


; #FUNCTION# ===================================================================================================
; Name...........: _Extractlha
; Description ...: Extract with lha.exe
; Syntax.........: _Extractlha($iPathLha , $iPathTarget)
; Parameters ....: $iPathLha	- Lha Path
;~ 				   $iPathTarget	- Target folder path
; Return values .: Success      - Return the target folder path
;                  Failure      - -1
; Author ........: Elom, based on _Unzip
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _Extractlha($iPathLha, $iPathTarget)
	Local $sRun, $iPid, $_StderrRead
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPathLha, $sDrive, $sDir, $sFileName, $iExtension)
	If StringLower($iExtension) <> ".lha" Then
		_LOG("Not a LHA file : " & $iPathLha, 2, $iLOGPath)
		Return -1
	EndIf
	$sRun = '"' & $iScriptPath & '\Ressources\lha.exe" x -fv "' & $iPathLha & '" -w "' & $iPathTarget & '"'
	_LOG("lha command: " & $sRun, 1, $iLOGPath)
	$iPid = Run($sRun, '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	While ProcessExists($iPid)
		$_StderrRead = StderrRead($iPid)
		If Not @error And $_StderrRead <> '' Then
			If (StringInStr($_StderrRead, 'LHa: Error:') Or StringInStr($_StderrRead, 'LHa: Fatal error:')) And Not StringInStr($_StderrRead, 'melted') Then
				_LOG("Error while decompressing LHA " & $iPathLha, 2, $iLOGPath)
				Return -2
			EndIf
		EndIf
	WEnd
	_LOG("Decompressed LHA : " & $iPathLha & " to " & $iPathTarget, 0, $iLOGPath)
	Return $iPathTarget
EndFunc	  ;==>_Extractlha




; #FUNCTION# ===================================================================================================
; Name...........: _URIEncode
; Description ...: Create a valid URL
; Syntax.........: _URIEncode($sData)
; Parameters ....: $sData	- string to Encode
; Return values .:
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; https://www.autoitscript.com/forum/topic/95850-url-encoding/
; Example .......; No
Func _URIEncode($sData)
	Local $aData = StringSplit(BinaryToString(StringToBinary($sData, 4), 1), "")
	Local $nChar
	$sData = ""
	For $I = 1 To $aData[0]
		$nChar = Asc($aData[$I])
		Switch $nChar
			Case 45, 46, 48 - 57, 65 To 90, 95, 97 To 122, 126
				$sData &= $aData[$I]
			Case 32
				$sData &= "+"
			Case Else
				$sData &= "%" & Hex($nChar, 2)
		EndSwitch
	Next
	Return $sData
EndFunc   ;==>_URIEncode

; #FUNCTION# ===================================================================================================
; Name...........: _LOG_Ceation
; Description ...: Create the Log file with starting info
; Syntax.........: _LOG_Ceation()
; Parameters ....: $iLOGPath	- Path to log File
; Return values .:
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _LOG_Ceation($iLOGPathC = @ScriptDir & "\Log.txt")
	Local $iVersion
	If @Compiled Then
		$iVersion = FileGetVersion(@ScriptFullPath)
	Else
		$iVersion = 'In Progress'
	EndIf
	FileDelete($iLOGPathC)
	If Not _FileCreate($iLOGPathC) Then MsgBox(4096, "Error", " Erreur creation du Fichier LOG      error:" & @error)
	_LOG(@ScriptFullPath & " (" & $iVersion & ")", 0, $iLOGPathC)
	_LOG(@OSVersion & "(" & @OSArch & ") - " & @OSLang, 0, $iLOGPathC)
EndFunc   ;==>_LOG_Ceation

; #FUNCTION# ===================================================================================================
; Name...........: _LOG
; Description ...: Write log message in file and in console
; Syntax.........: _LOG([$iMessage = ""],[$iLOGType = 0],[$iVerboseLVL = 0],[$iLOGPath = @ScriptDir & "\Log.txt"])
; Parameters ....: $iLOGPath		- Path to log File
;                  $iMessage	- Message
;                  $iLOGType	- Log Type (0 = Standard, 1 = Warning, 2 = Critical)
; Return values .:
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _LOG($iMessage = "", $iLOGType = 0, $iLOGPath = @ScriptDir & "\Log.txt")
	Local $tCur, $dtCur, $iTimestamp
;~ 	Local $iVerboseLVL = IniRead($iINIPath, "GENERAL", "$vVerbose", 0)
	$tCur = _Date_Time_GetLocalTime()
	$dtCur = _Date_Time_SystemTimeToArray($tCur)
	$iTimestamp = "[" & StringRight("0" & $dtCur[3], 2) & ":" & StringRight("0" & $dtCur[4], 2) & ":" & StringRight("0" & $dtCur[5], 2) & "] - "
	Switch $iLOGType
		Case 0
			FileWrite($iLOGPath, $iTimestamp & $iMessage & @CRLF)
			ConsoleWrite($iMessage & @CRLF)
		Case 1
			If $iLOGType <= $iVerboseLVL Then FileWrite($iLOGPath, $iTimestamp & "> " & $iMessage & @CRLF)
			ConsoleWrite("+" & $iMessage & @CRLF)
		Case 2
			If $iLOGType <= $iVerboseLVL Then
				FileWrite($iLOGPath, $iTimestamp & "/!\ " & $iMessage & @CRLF)
			EndIf
			ConsoleWrite("!" & $iMessage & @CRLF)
		Case 3
;~ 			FileWrite($iLOGPath, $iTimestamp & $iMessage & @CRLF)
			ConsoleWrite(">----" & $iMessage & @CRLF)
	EndSwitch
EndFunc   ;==>_LOG

; #FUNCTION# ====================================================================================================================
; Name ..........: _CheckURL
; Description ...: Check if an URL Exist
; Syntax ........: _CheckURL($vUrl)
; Parameters ....: $vUrl            - URL to test
; Return values .: Success - 1
;                  Failure - -1 (known error)
;~ 							 -2 (Unknown error)
; Author ........: Screech
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CheckUrl($vUrl = "https://www.screenscraper.fr/api/ssuserInfos.php")
	_LOG("Testing : " & $vUrl, 3, $iLOGPath)
	Local $Timer = TimerInit()
	Local $aURL = _WinHttpCrackUrl($vUrl)
	Local $sScheme = $aURL[0]
	Local $sDomain = $aURL[2]
	Local $sPage = $aURL[6]
	Local $sExtra = $aURL[7]
;~  	_ArrayDisplay($aURL) ; Debug
	; Initialize and get session handle
	Local $hOpen = _WinHttpOpen()
	; Get connection handle
	Local $hConnect = _WinHttpConnect($hOpen, $sDomain)
	; Make a Simple request
	Switch $sScheme
		Case "http"
			_LOG($sScheme & " Request", 3, $iLOGPath)
			$hRequest = _WinHttpSimpleSendRequest($hConnect, Default, $sPage & $sExtra)
		Case "https"
			_LOG($sScheme & " Request", 3, $iLOGPath)
			$hRequest = _WinHttpSimpleSendSSLRequest($hConnect, Default, $sPage & $sExtra)
		Case Else
			_LOG($sScheme & " - Not an HTTP or HTTPS url", 2, $iLOGPath)
	EndSwitch
	; Get full header
	Local $sReturned = StringMid(_WinHttpQueryHeaders($hRequest), 10, 3)
	; See what's returned
	Switch $sReturned
		Case 200
			_LOG($sDomain & $sPage & " - OK (200) - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 3, $iLOGPath)
			Return 1
		Case 400
			_LOG($sDomain & $sPage & " - Problème dans les parametres d'url - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case 401
			_LOG($sDomain & $sPage & " - API fermé pour les non-inscrit a ScreenScraper / les membres inactifs - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case 403
			_LOG($sDomain & $sPage & " - Erreur de login developpeur - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case 404
			_LOG($sDomain & $sPage & " - Aucune concordance trouvée ! - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case 426
			_LOG($sDomain & $sPage & " - Le logiciel de scrap a été bloqué par ScreenScraper (gestion des versions obsolètes de logiciel ou non conforme aux régles de ScreenScraper) - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case 429
			_LOG($sDomain & $sPage & " - Nombre de connexions en cours supérieur au nombres de connexions maximum autorisés - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -1
		Case Else
			_LOG($sDomain & $sPage & " - No referenced Status : " & $sReturned & " - " & Round((TimerDiff($Timer) / 1000), 2) & "s", 2, $iLOGPath)
			Return -2
	EndSwitch
	; Close handles when they are not needed any more
	_WinHttpCloseHandle($hRequest)
	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)
EndFunc   ;==>_CheckUrl

; #FUNCTION# ====================================================================================================================
; Name ..........: _CheckURL2
; Description ...: Check if an URL Exist
; Syntax ........: _CheckURL2($sTestUrl)
; Parameters ....: $sTestUrl            - URL to test
; Return values .: Success - 1
;                  Failure - 0
; Author ........: DaleHohm
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/22343-is-there-a-way-to-check-if-a-url-exists-without-calling-it/
; Example .......:
; ===============================================================================================================================
Func _CheckURL2($sTestUrl = "https://www.screenscraper.fr/api/ssuserInfos.php")
	$sTestUrl = "http://www.google.fr"
	_LOG("Test de l'URL : " & $sTestUrl, 0, $iLOGPath)

	Local $Timer = TimerInit()
	$oHttpRequest = ""
	$oHttpRequest = ObjCreate("MSXML2.ServerXMLHTTP")
	$ResolveTimeout = 500
	$ConnectTimeout = 500
	$SendTimeout = 500
	$ReceiveTimeout = 500

	$oHttpRequest.SetTimeouts($ResolveTimeout, $ConnectTimeout, $SendTimeout, $ReceiveTimeout)
	$oHttpRequest.Open("GET", $sTestUrl)
	$oHttpRequest.Send
	$urlStatus = $oHttpRequest.Status

;~     Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
;~     $oHTTP.Open("HEAD", $sTestUrl, False)
;~     If @error Then _LOG("Opening HEAD error", 2, $iLOGPath)
;~     $oHTTP.Send()
;~     If @error Then _LOG("Error 105 (net::ERR_NAME_NOT_RESOLVED)", 2, $iLOGPath)
;~     Local $urlStatus = $oHTTP.Status
;~     If @error Then _LOG("Error 118 (net::ERR_CONNECTION_TIMED_OUT)", 2, $iLOGPath)

	_LOG("Timer : " & Round((TimerDiff($Timer) / 1000), 2), 0, $iLOGPath)

	Switch $urlStatus
		Case 200
			_LOG($sTestUrl & " OK (200)", 3, $iLOGPath)
			Return 1
		Case 404
			_LOG("Connection Successful! (" & $urlStatus & ") - URL Not Found: " & $sTestUrl, 2, $iLOGPath)
			Return -1
		Case 105
			_LOG("Connection error: ERR_NAME_NOT_RESOLVED (" & $urlStatus & ") - URL is Not Found: " & $sTestUrl, 2, $iLOGPath)
			Return -1
		Case Else
			_LOG("Connection error! (" & $urlStatus & ") - URL: " & $sTestUrl, 2, $iLOGPath)
			Return -2
	EndSwitch
EndFunc   ;==>_CheckURL2

; #FUNCTION# ===================================================================================================
; Name...........: _Download
; Description ...: Download URL to a file with @Error and TimeOut
; Syntax.........: _Download($iURL, $iPath, $iTimeOut = 20, $iCRC = default)
; Parameters ....: $iURL		- URL to download
;                  $iPath		- Path to download
;                  $iTimeOut	- Time to wait before time out in second
; Return values .: Success      - Return the path of the download
;                  Failure      - -1 : Error
;~ 								- -2 : Time Out
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _Download($iURL, $iPath, $iTimeOut = 50, $iCRC = Default)
	Local $inetgettime = 0, $aData, $hDownload, $vDataDL = 0
	If $iURL = "" Then
		_LOG("Nothing to Downloaded : " & $iPath, 2, $iLOGPath)
		Return -1
	EndIf

;~ 	If _CheckUrl($iURL) <0 Then Return -1

	$hDownload = InetGet($iURL, $iPath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	Do
		Sleep(250)
		$aData = InetGetInfo($hDownload)
		If $aData[$INET_DOWNLOADREAD] > $vDataDL Then
			$vDataDL = $aData[$INET_DOWNLOADREAD]
		Else
			$inetgettime = $inetgettime + 0.25
		EndIf
		If $inetgettime > $iTimeOut Then
			InetClose($hDownload)
			_LOG("File Downloading URL : " & $iURL, 3, $iLOGPath)
			_LOG("Timed out (" & $inetgettime & "s) for downloading file : " & $iPath, 1, $iLOGPath)
			FileDelete($iPath)
			Return -2
		EndIf
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE) ; Check if the download is complete.


	$aData = InetGetInfo($hDownload)
	If @error Then
		_LOG("File Downloaded ERROR InetGetInfo : " & $iPath, 2, $iLOGPath)
		InetClose($hDownload)
		FileDelete($iPath)
		Return -1
	EndIf

	InetClose($hDownload)
	If $aData[$INET_DOWNLOADSUCCESS] Then
		If ($aData[$INET_DOWNLOADSIZE] <> 0 And $aData[$INET_DOWNLOADREAD] <> $aData[$INET_DOWNLOADSIZE]) Or FileGetSize($iPath) < 50 Then
			_LOG("Error Downloading URL : " & $iURL, 3, $iLOGPath)
			_LOG("Error Downloading File : " & $iPath, 2, $iLOGPath)
			_LOG("Error File Line 1 : " & FileReadLine($iPath), 2, $iLOGPath)
			_LOG("Bytes read: " & $aData[$INET_DOWNLOADREAD], 2, $iLOGPath)
			_LOG("Size: " & $aData[$INET_DOWNLOADSIZE], 2, $iLOGPath)
			FileDelete($iPath)
			Return -1
		EndIf

		If $iCRC <> Default Then
			$vDlCRC = StringRight(_CRC32ForFile($iPath), 8)
			If $vDlCRC <> $iCRC Then
				_LOG("Error CRC File (" & $vDlCRC & " <> " & $iCRC & ") : " & $iPath, 2, $iLOGPath)
;~ 				Return -1
			Else
				_LOG(">>> CRC OK (" & $vDlCRC & " = " & $iCRC & ") : " & $iPath, 1, $iLOGPath)
			EndIf
		EndIf
		_LOG("File Downloading URL : " & $iURL, 3, $iLOGPath)
		_LOG("File Downloaded Path : " & $iPath, 1, $iLOGPath)
		Return $iPath
	Else
		_LOG("Error Downloading URL : " & $iURL, 3, $iLOGPath)
		_LOG("Error Downloading File : " & $iPath, 2, $iLOGPath)
		_LOG("Bytes read: " & $aData[$INET_DOWNLOADREAD], 2, $iLOGPath)
		_LOG("Size: " & $aData[$INET_DOWNLOADSIZE], 2, $iLOGPath)
		_LOG("Complete: " & $aData[$INET_DOWNLOADCOMPLETE], 2, $iLOGPath)
		_LOG("successful: " & $aData[$INET_DOWNLOADSUCCESS], 2, $iLOGPath)
		_LOG("@error: " & $aData[$INET_DOWNLOADERROR], 2, $iLOGPath)
		_LOG("@extended: " & $aData[$INET_DOWNLOADEXTENDED], 2, $iLOGPath)
		FileDelete($iPath)
		Return -1
	EndIf
EndFunc   ;==>_Download

; #FUNCTION# ===================================================================================================
; Name...........: _DownloadWRetry
; Description ...: Download URL to a file with @Error and TimeOut With Retry
; Syntax.........: _DownloadWRetry($iURL, $iPath, $iRetry = 3, $iTimeOut = 20, $iCRC = default)
; Parameters ....: $iURL		- URL to download
;                  $iPath		- Path to download
;~ 				   $iRetry		- Number of retry
; Return values .: Success      - Return the path of the download
;                  Failure      - -1 : Error
;~ 								- -2 : Time Out
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _DownloadWRetry($iURL, $iPath, $iRetry = 3, $iTimeOut = 50, $iCRC = Default)
	Local $iCount = 0, $iResult = -1, $vTimer = TimerInit()
	While $iResult < 0 And $iCount < $iRetry
		$iCount = $iCount + 1
		$iResult = _Download($iURL, $iPath, $iTimeOut, $iCRC)
	WEnd
	_LOG("-In " & $iCount & " try and " & Round((TimerDiff($vTimer) / 1000), 2) & "s", 1, $iLOGPath)
	Return $iResult
EndFunc   ;==>_DownloadWRetry

; #FUNCTION# ===================================================================================================
; Name...........: _MultiLang_LoadLangDef
; Description ...: Return a file size and convert to a readable form
; Syntax.........: _MultiLang_LoadLangDef($iLangPath, $vUserLang)
; Parameters ....: $iLangPath	- Path to the language
;                  $vUserLang	- User language code
; Return values .: Success      - Return the language files array
;                  Failure      - -1
; Author ........: Autoit Help
; Modified.......:
; Remarks .......: Brett Francis (BrettF)
; Related .......:
; Link ..........;
; Example .......; No
Func _MultiLang_LoadLangDef($iLangPath, $vUserLang)
	;Create an array of available language files
	; ** n=0 is the default language file
	; [n][0] = Display Name in Local Language (Used for Select Function)
	; [n][1] = Language File (Full path.  In this case we used a $iLangPath
	; [n][2] = [Space delimited] Character codes as used by @OS_LANG (used to select correct lang file)
	Local $aLangFiles[9][3]

	$aLangFiles[0][0] = "Français" ; French
	$aLangFiles[0][1] = $iLangPath & "\UXS-FRENCH.XML"
	$aLangFiles[0][2] = "040c " & _ ;French_Standard
			"080c " & _ ;French_Belgian
			"0c0c " & _ ;French_Canadian
			"100c " & _ ;French_Swiss
			"140c " & _ ;French_Luxembourg
			"180c" ;French_Monaco

	$aLangFiles[1][0] = "English (UK)" ;
	$aLangFiles[1][1] = $iLangPath & "\UXS-ENGLISHUK.XML"
	$aLangFiles[1][2] = "0809 " ;English_United_Kingdom

	$aLangFiles[2][0] = "English (US)" ;
	$aLangFiles[2][1] = $iLangPath & "\UXS-ENGLISHUS.XML"
	$aLangFiles[2][2] = "0409 " & _ ;English_United_States
			"0809 " & _ ;English_United_Kingdom
			"0c09 " & _ ;English_Australia
			"1009 " & _ ;English_Canadian
			"1409 " & _ ;English_New_Zealand
			"1809 " & _ ;English_Irish
			"1c09 " & _ ;English_South_Africa
			"2009 " & _ ;English_Jamaica
			"2409 " & _ ;English_Caribbean
			"2809 " & _ ;English_Belize
			"2c09 " & _ ;English_Trinidad
			"3009 " & _ ;English_Zimbabwe
			"3409" ;English_Philippines

	$aLangFiles[3][0] = "Espanol" ; Spanish
	$aLangFiles[3][1] = $iLangPath & "\UXS-SPANISH.XML"
	$aLangFiles[3][2] = "040A " & _ ;Spanish - Spain
			"080A " & _ ;Spanish - Mexico
			"0C0A " & _ ;Spanish - Spain
			"100A " & _ ;Spanish - Guatemala
			"140A " & _ ;Spanish - Costa Rica
			"180A " & _ ;Spanish - Panama
			"1C0A " & _ ;Spanish - Dominican Republic
			"200A " & _ ;Spanish - Venezuela
			"240A " & _ ;Spanish - Colombia
			"280A " & _ ;Spanish - Peru
			"2C0A " & _ ;Spanish - Argentina
			"300A " & _ ;Spanish - Ecuador
			"340A " & _ ;Spanish - Chile
			"380A " & _ ;Spanish - Uruguay
			"3C0A " & _ ;Spanish - Paraguay
			"400A " & _ ;Spanish - Bolivia
			"440A " & _ ;Spanish - El Salvador
			"480A " & _ ;Spanish - Honduras
			"4C0A " & _ ;Spanish - Nicaragua
			"500A " & _ ;Spanish - Puerto Rico
			"540A " ;Spanish - United State

	$aLangFiles[4][0] = "Deutsch" ; German
	$aLangFiles[4][1] = $iLangPath & "\UXS-GERMAN.XML"
	$aLangFiles[4][2] = "0407 " & _ ;German - Germany
			"0807 " & _ ;German - Switzerland
			"0C07 " & _ ;German - Austria
			"1007 " & _ ;German - Luxembourg
			"1407 " ;German - Liechtenstein

	$aLangFiles[5][0] = "Portugues" ; Portuguese
	$aLangFiles[5][1] = $iLangPath & "\UXS-PORTUGUESE.XML"
	$aLangFiles[5][2] = "0816 " & _ ;Portuguese - Portugal
			"0416 " ;Portuguese - Brazil

	$aLangFiles[6][0] = "Italian" ; Italian
	$aLangFiles[6][1] = $iLangPath & "\UXS-ITALIAN.XML"
	$aLangFiles[6][2] = "0410 " & _ ;Italian - Italy
			"0810 " ;Italian - Switzerland

	$aLangFiles[7][0] = "Dutch" ; Dutch
	$aLangFiles[7][1] = $iLangPath & "\UXS-DUTCH.XML"
	$aLangFiles[7][2] = "0413 " & _ ;Dutch - Netherlands
			"0813 " ;Dutch - Belgium

	$aLangFiles[8][0] = "Japanese" ; Japanese
	$aLangFiles[8][1] = $iLangPath & "\UXS-JAPANESE.XML"
	$aLangFiles[8][2] = "0411 " ;Japanese - Japan

	;Set the available language files, names, and codes.
	_MultiLang_SetFileInfo($aLangFiles)
	If @error Then
		MsgBox(48, "Error", "Could not set file info.  Error Code " & @error)
		_LOG("Could not set file info.  Error Code " & @error, 2, $iLOGPath)
		Exit
	EndIf

	;Check if the loaded settings file exists.  If not ask user to select language.
	If $vUserLang = -1 Then
		;Create Selection GUI
		_LOG("Loading language :" & StringLower(@OSLang), 1, $iLOGPath)
		_MultiLang_LoadLangFile(StringLower(@OSLang))
		$vUserLang = _SelectGUI($aLangFiles, StringLower(@OSLang), "langue", 1)
		If @error Then
			MsgBox(48, "Error", "Could not create selection GUI.  Error Code " & @error)
			_LOG("Could not create selection GUI.  Error Code " & @error, 2, $iLOGPath)
			Exit
		EndIf
		IniWrite($iINIPath, "LAST_USE", "$vUserLang", $vUserLang)
	EndIf

	_LOG("Language Selected : " & $vUserLang, 0, $iLOGPath)

	;If you supplied an invalid $vUserLang, we will load the default language file
	If _MultiLang_LoadLangFile($vUserLang) = 2 Then MsgBox(64, "Information", "Just letting you know that we loaded the default language file")
	If @error Then
		MsgBox(48, "Error", "Could not load lang file.  Error Code " & @error)
		_LOG("Could not load lang file.  Error Code " & @error, 2, $iLOGPath)
		Exit
	EndIf
	Return $aLangFiles
EndFunc   ;==>_MultiLang_LoadLangDef

; #FUNCTION# ===================================================================================================
; Name...........: _SelectGUI
; Description ...: GUI to select from an array
; Syntax.........: _SelectGUI($aSelectionItem , [$default = -1] , [$vText = "standard"], [$vLanguageSelector = 0])
; Parameters ....: $aSelectionItem	- Array with info (see Remarks)
;                  $vLanguageSelector- If used as language selector
;                  $default			- Default value if nothing selected
; Return values .: Success      - Return the selected item
;                  Failure      - -1
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......: $aSelectionItem is a 2D Array
;~ 					[Name viewed][Note Used][Returned value]
; Related .......:
; Link ..........;
; Example .......; No
Func _SelectGUI($aSelectionItem, $default = -1, $vText = "standard", $vLanguageSelector = 0)
	If $aSelectionItem = -1 Or IsArray($aSelectionItem) = 0 Then
		_LOG("Selection Array Invalid", 2, $iLOGPath)
		Return -1
	EndIf
	If $vLanguageSelector = 1 Then
		$_gh_aLangFileArray = $aSelectionItem
		If $default = -1 Then $default = @OSLang
	EndIf


	Local $_Selector_gui_GUI = GUICreate(_MultiLang_GetText("win_sel_" & $vText & "_Title"), 340, 165, -1, -1, BitOR($WS_POPUP, $WS_BORDER), -1)
	Local $_Selector_gui_Pic = GUICtrlCreatePic($iScriptPath & "\" & "Ressources\Images\Wizard\UXS_Wizard_Half.jpg", 2, 2, 100, 160, -1, -1)
	Local $_Selector_gui_Group = GUICtrlCreateGroup(_MultiLang_GetText("win_sel_" & $vText & "_Title"), 108, 1, 230, 163, -1, -1)
	GUICtrlSetBkColor(-1, "0xF0F0F0")
	Local $_Selector_gui_Label = GUICtrlCreateLabel(_MultiLang_GetText("win_sel_" & $vText & "_text"), 116, 25, 215, 40, $SS_CENTERIMAGE, -1)
	GUICtrlSetBkColor(-1, "-2")
	Local $_Selector_gui_Combo = GUICtrlCreateCombo("(" & _MultiLang_GetText("win_sel_" & $vText & "_Title") & ")", 116, 75, 215, 21, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE)) ;BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "")
	Local $_Selector_gui_Button = GUICtrlCreateButton(_MultiLang_GetText("win_sel_" & $vText & "_button"), 231, 125, 100, 30, -1, -1)
;~ 	$B_SelectorCancel = GUICtrlCreateButton("Cancel",116,125,100,30,-1,-1)

;~ 	Local $_Selector_gui_GUI = GUICreate(_MultiLang_GetText("win_sel_" & $vText & "_Title"), 230, 100)
;~ 	Local $_Selector_gui_Combo = GUICtrlCreateCombo("(" & _MultiLang_GetText("win_sel_" & $vText & "_Title") & ")", 8, 48, 209, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE)) ;BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
;~ 	Local $_Selector_gui_Button = GUICtrlCreateButton(_MultiLang_GetText("win_sel_" & $vText & "_button"), 144, 72, 75, 25)
;~ 	Local $_Selector_gui_Label = GUICtrlCreateLabel(_MultiLang_GetText("win_sel_" & $vText & "_text"), 8, 8, 212, 33)

	;Create List of available Items
	For $I = 0 To UBound($aSelectionItem) - 1
		GUICtrlSetData($_Selector_gui_Combo, $aSelectionItem[$I][0], "(" & _MultiLang_GetText("win_sel_" & $vText & "_Title") & ")")
	Next

	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $_Selector_gui_Button
				ExitLoop
		EndSwitch
	WEnd
	Local $_selected = GUICtrlRead($_Selector_gui_Combo)
	GUIDelete($_Selector_gui_GUI)

;~ 	MsgBox(0,"$_selected",$_selected)
;~ 	_ArrayDisplay($aSelectionItem,"$aSelectionItem")

	For $I = 0 To UBound($aSelectionItem) - 1
		If $aSelectionItem[$I][0] = $_selected Then
			If $vLanguageSelector = 1 Then
				_LOG("Value selected : " & StringLeft($aSelectionItem[$I][2], 4), 1, $iLOGPath)
				Return StringLeft($aSelectionItem[$I][2], 4)
			Else
				_LOG("Value selected : " & $aSelectionItem[$I][2], 1, $iLOGPath)
				Return $aSelectionItem[$I][2]
			EndIf
		EndIf
	Next
	_LOG("No Value selected (Default = " & $default & ")", 1, $iLOGPath)
	Return $default
EndFunc   ;==>_SelectGUI

; #FUNCTION# ===================================================================================================
; Name...........: _ByteSuffix($iBytes)
; Description ...: Return a file size and convert to a readable form
; Syntax.........: _ByteSuffix($iBytes)
; Parameters ....: $iBytes		- Size from a FileGetSize() function
; Return values .: Success      - Return a string with Size and suffixe
; Author ........: Autoit Help
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; yes in FileGetSize autoit Help
Func _ByteSuffix($iBytes)
	Local $iIndex = 0, $aArray = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes) & $aArray[$iIndex]
EndFunc   ;==>_ByteSuffix

; #FUNCTION# ===================================================================================================
; Name...........: _IsChecked
; Description ...: Return the state of a control Id
; Syntax.........: _IsChecked($idControlID)
; Parameters ....: $idControlID		- Control Id to test
; Return values .: Success      - $GUI_CHECKED
;                  Failure      - $GUI_UNCHECKED
; Author ........: Autoit Help
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; yes in autoit Help
Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; #FUNCTION# ===================================================================================================
; Name...........: _FormatElapsedTime
; Description ...: Return a formated time
; Syntax.........: _FormatElapsedTime($Input_Seconds)
; Parameters ....: $Input_Seconds	- Time in seconds
; Return values .: Success      - Return a formated string for time
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _FormatElapsedTime($nr_sec)
	$sec2time_hour = Int($nr_sec / 3600)
	$sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
	$sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
	Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
EndFunc   ;==>_FormatElapsedTime


; #FUNCTION# ===================================================================================================
; Name...........: _FormatElapsedTime
; Description ...: Return a formated time
; Syntax.........: _FormatElapsedTime($Input_Seconds)
; Parameters ....: $Input_Seconds	- Time in seconds
; Return values .: Success      - Return a formated string for time
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _FormatElapsedTime2($Input_Seconds)
	If $Input_Seconds < 1 Then Return
	Global $ElapsedMessage = ''
	Global $Input = $Input_Seconds
	Switch $Input_Seconds
		Case 0 To 59
			GetSeconds()
		Case 60 To 3599
			GetMinutes()
			GetSeconds()
		Case 3600 To 86399
			GetHours()
			GetMinutes()
			GetSeconds()
		Case Else
			GetDays()
			GetHours()
			GetMinutes()
			GetSeconds()
	EndSwitch
	Return $ElapsedMessage
EndFunc   ;==>_FormatElapsedTime2

Func GetDays()
	$Days = Int($Input / 86400)
	$Input -= ($Days * 86400)
	$ElapsedMessage &= $Days & ' d, '
	Return $ElapsedMessage
EndFunc   ;==>GetDays

Func GetHours()
	$Hours = Int($Input / 3600)
	$Input -= ($Hours * 3600)
	$ElapsedMessage &= $Hours & ' h, '
	Return $ElapsedMessage
EndFunc   ;==>GetHours

Func GetMinutes()
	$Minutes = Int($Input / 60)
	$Input -= ($Minutes * 60)
	$ElapsedMessage &= $Minutes & ' min, '
	Return $ElapsedMessage
EndFunc   ;==>GetMinutes

Func GetSeconds()
	$ElapsedMessage &= Int($Input) & ' sec.'
	Return $ElapsedMessage
EndFunc   ;==>GetSeconds

Func _MakeTEMPFile($iPath, $iPath_Temp)
	;Working on temporary picture
	FileDelete($iPath_Temp)
	If Not FileCopy($iPath, $iPath_Temp, $FC_OVERWRITE + $FC_CREATEPATH) Then
		Sleep(250)
		If Not FileCopy($iPath, $iPath_Temp, $FC_OVERWRITE + $FC_CREATEPATH) Then
			_LOG("Error copying " & $iPath & " to " & $iPath_Temp & " (" & FileGetSize($iPath) & ")", 2, $iLOGPath)
			Return -1
		EndIf
	EndIf
	If Not FileDelete($iPath) Then
		Sleep(250)
		If Not FileDelete($iPath) Then
			_LOG("Error deleting " & $iPath, 2, $iLOGPath)
			Return -1
		EndIf
	EndIf
	_LOG($iPath & " to temp OK : " & $iPath_Temp, 1, $iLOGPath)
	Return $iPath_Temp
EndFunc   ;==>_MakeTEMPFile

Func _Coalesce($vValue1, $vValue2, $vTestValue = "")
	If $vValue1 = $vTestValue Then Return $vValue2
	Return $vValue1
EndFunc   ;==>_Coalesce

Func _KillScrapeEngine($iScraper)
	$aPID = ProcessList($iScraper)
;~ 	_ArrayDisplay($aPID,"$aPID")
	For $Boucle = 1 To $aPID[0][0]
		_LOG("Killing Process : " & $aPID[$Boucle][0] & " - " & $aPID[$Boucle][1], 0, $iLOGPath)
;~ 		_SendMail($sMailSlotCancel & $vBoucle, "CANCELED")
		ProcessClose($aPID[$Boucle][1])
		If @error Then _LOG("Error Killing Process : " & $aPID[$Boucle][0] & " - " & $aPID[$Boucle][1] & "(" & @error & ")", 2, $iLOGPath)
	Next

EndFunc   ;==>_KillScrapeEngine

#EndRegion MISC Function

#Region GDI Function
; #FUNCTION# ===================================================================================================
; Name...........: _Compression
; Description ...: Optimize PNG
; Syntax.........: _Compression($iPath [, $isoft = 'pngquant.exe', $iParamater = '--force --verbose --ordered --speed=1 --quality=50-90 --ext .png'])
; Parameters ....: $iPath		- Path to the picture
;~ 				   $isoft		- exe to use
;~ 				   $iParamater	- parameter to use
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: inspiration : wakillon
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; https://www.autoitscript.com/forum/topic/122168-tinypicsharer-v-1034-new-version-08-june-2013/
Func _Compression($iPath, $isoft = 'pngquant.exe', $iParamater = '--force --verbose --ordered --speed=1 --quality=50-90 --ext .png')
	Local $sRun, $iPid, $_StderrRead
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	If StringLower($iExtension) <> ".png" Then
		_LOG("Not a PNG file : " & $iPath, 2, $iLOGPath)
		Return -1
	EndIf
	$vPathSize = _ByteSuffix(FileGetSize($iPath))
	$sRun = '"' & $iScriptPath & '\Ressources\pngquant.exe" ' & $iParamater & ' "' & $iPath & '"'
	_LOG("PNGQuant command: " & $sRun, 1, $iLOGPath)
	$iPid = Run($sRun, '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	While ProcessExists($iPid)
		$_StderrRead = StderrRead($iPid)
		If Not @error And $_StderrRead <> '' Then
			If StringInStr($_StderrRead, 'error') And Not StringInStr($_StderrRead, 'No errors') Then
				_LOG("Error while optimizing " & $iPath, 2, $iLOGPath)
				Return -1
			EndIf
		EndIf
	WEnd
	$vPathSizeOptimized = _ByteSuffix(FileGetSize($iPath))
	_LOG("PNG Optimization (PNGQuant): " & $iPath & "(" & $vPathSize & " -> " & $vPathSizeOptimized & ")", 0, $iLOGPath)
	Return $iPath
EndFunc   ;==>_Compression

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_RelativePos
; Description ...: Calculate relative position
; Syntax.........: _GDIPlus_RelativePos($iValue, $iValueMax)
; Parameters ....: $iValue		- Value
;                  $iValueMax	- Value Max
; Return values .: Return the relative Value
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_RelativePos($iValue, $iValueMax)
	If StringLeft($iValue, 1) = '%' Then Return Int($iValueMax * StringTrimLeft($iValue, 1))
	Return $iValue
EndFunc   ;==>_GDIPlus_RelativePos

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_ResizeMax
; Description ...: Resize a Picture to the Max Size in Width and/or Height
; Syntax.........: _GDIPlus_ResizeMax($iPath, $iMAX_Width, $iMAX_Height)
; Parameters ....: $iPath		- Path to the picture
;                  $iMAX_Width	- Max width
;                  $iMAX_Height	- Max height
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_ResizeMax($iPath, $iMAX_Width, $iMAX_Height)
	Local $hImage, $iWidth, $iHeight, $iWidth_New, $iHeight_New, $iRatio, $hImageResized
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp, $iResized
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-RESIZE_Temp" & $iExtension
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$iWidth = _GDIPlus_ImageGetWidth($hImage)
	If $iWidth = 4294967295 Then $iWidth = 0 ;4294967295 en cas d'erreur.
	$iHeight = _GDIPlus_ImageGetHeight($hImage)
	If $iWidth = -1 Or $iHeight = -1 Then MsgBox(0, "error", $iPath & " or " & $iPath_Temp & " Problem")
	$iRatio = $iHeight / $iWidth
	If $iMAX_Width <= 0 And $iMAX_Height > 0 Then $iMAX_Width = $iMAX_Height / $iRatio
	If $iMAX_Height <= 0 And $iMAX_Width > 0 Then $iMAX_Height = $iMAX_Width * $iRatio
	$iHeight_New = $iMAX_Height
	$iWidth_New = $iMAX_Height / $iRatio
	If $iWidth_New > $iMAX_Width Then
		$iWidth_New = $iMAX_Width
		$iHeight_New = $iWidth_New * $iRatio
;~ 		_LOG("$iWidth_New too BIG $iSize_New " & $iWidth_New & " x " & $iHeight_New & "(" & $iHeight_New / $iWidth_New & ")", 2, $iLOGPath)
	EndIf
	$iWidth_New = Int($iWidth_New)
	$iHeight_New = Int($iHeight_New)
	If $iWidth <> $iWidth_New Or $iHeight <> $iHeight_New Then
		$iResized = 1
		_LOG("Resize Max : " & $iPath, 0, $iLOGPath) ; Debug
		_LOG("Origine = " & $iWidth & "x" & $iHeight, 1, $iLOGPath) ; Debug
		_LOG("Finale = " & $iWidth_New & "x" & $iHeight_New, 1, $iLOGPath) ; Debug
	Else
		$iResized = 0
		_LOG("No Resizing : " & $iPath, 0, $iLOGPath) ; Debug
		_LOG("Origine = " & $iWidth & "x" & $iHeight, 1, $iLOGPath) ; Debug
		_LOG("Finale = " & $iWidth_New & "x" & $iHeight_New, 1, $iLOGPath) ; Debug
	EndIf
	$hImageResized = _GDIPlus_ImageResize($hImage, $iWidth_New, $iHeight_New)
	_GDIPlus_ImageSaveToFile($hImageResized, $iPath)
	_GDIPlus_ImageDispose($hImageResized)
	_WinAPI_DeleteObject($hImageResized)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iResized
EndFunc   ;==>_GDIPlus_ResizeMax

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_Rotation
; Description ...: Rotate a picture
; Syntax.........: _GDIPlus_Rotation($iPath, $iRotation = 0)
; Parameters ....: $iPath		- Path to the picture
;                  $iRotation	- Rotation Value
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......: 	0 - No rotation and no flipping (A 180-degree rotation, a horizontal flip and then a vertical flip)
;~ 					1 - A 90-degree rotation without flipping (A 270-degree rotation, a horizontal flip and then a vertical flip)
;~ 					2 - A 180-degree rotation without flipping (No rotation, a horizontal flip followed by a vertical flip)
;~ 					3 - A 270-degree rotation without flipping (A 90-degree rotation, a horizontal flip and then a vertical flip)
;~ 					4 - No rotation and a horizontal flip (A 180-degree rotation followed by a vertical flip)
;~ 					5 - A 90-degree rotation followed by a horizontal flip (A 270-degree rotation followed by a vertical flip)
;~ 					6 - A 180-degree rotation followed by a horizontal flip (No rotation and a vertical flip)
;~ 					7 - A 270-degree rotation followed by a horizontal flip (A 90-degree rotation followed by a vertical flip)
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_Rotation($iPath, $iRotation = 0)
	Local $hImage, $iWidth, $iHeight, $iWidth_New, $iHeight_New
	#forceref $hImage, $iWidth, $iHeight, $iWidth_New, $iHeight_New
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-ROTATE_Temp" & $iExtension
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	If $iRotation = '' Or $iRotation > 7 Then $iRotation = 0
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$iWidth = _GDIPlus_ImageGetWidth($hImage)
	If $iWidth = 4294967295 Then $iWidth = 0 ;4294967295 en cas d'erreur.
	$iHeight = _GDIPlus_ImageGetHeight($hImage)
	_GDIPlus_ImageRotateFlip($hImage, $iRotation)
	$iWidth_New = _GDIPlus_ImageGetWidth($hImage)
	If $iWidth = 4294967295 Then $iWidth = 0 ;4294967295 en cas d'erreur.
	$iHeight_New = _GDIPlus_ImageGetHeight($hImage)
	_LOG("ROTATION (" & $iRotation & ") : " & $iPath, 0, $iLOGPath) ; Debug
	_GDIPlus_ImageSaveToFile($hImage, $iPath)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath
EndFunc   ;==>_GDIPlus_Rotation

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_Transparency
; Description ...: Apply transparency on a picture
; Syntax.........: _GDIPlus_Transparency($iPath, $iTransLvl)
; Parameters ....: $iPath		- Path to the picture
;                  $iTransLvl	- Transparency level
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
;; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_Transparency($iPath, $iTransLvl)
;~ 	MsgBox(0,"DEBUG","_GDIPlus_Transparency");Debug
	Local $hImage, $ImageWidth, $ImageHeight, $hGui, $hGraphicGUI, $hBMPBuff, $hGraphic
	Local $MergedImageBackgroundColor = 0x00000000
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-TRANS_Temp.PNG"
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	$iPath = $sDrive & $sDir & $sFileName & ".png"
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$ImageWidth = _GDIPlus_ImageGetWidth($hImage)
	If $ImageWidth = 4294967295 Then $ImageWidth = 0 ;4294967295 en cas d'erreur.
	$ImageHeight = _GDIPlus_ImageGetHeight($hImage)
	$hGui = GUICreate("", $ImageWidth, $ImageHeight)
	$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGui) ;Draw to this graphics, $hGraphicGUI, to display on GUI
	$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($ImageWidth, $ImageHeight, $hGraphicGUI) ; $hBMPBuff is a bitmap in memory
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff) ; Draw to this graphics, $hGraphic, being the graphics of $hBMPBuff
	_GDIPlus_GraphicsClear($hGraphic, $MergedImageBackgroundColor)
	_GDIPlus_GraphicsDrawImageRectRectTrans($hGraphic, $hImage, 0, 0, "", "", "", "", "", "", 2, $iTransLvl)
	_LOG("Transparency (" & $iTransLvl & ") : " & $iPath, 0, $iLOGPath) ; Debug
	_GDIPlus_ImageSaveToFile($hBMPBuff, $iPath)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hGraphic)
	_GDIPlus_BitmapDispose($hBMPBuff)
	_WinAPI_DeleteObject($hBMPBuff)
	_GDIPlus_GraphicsDispose($hGraphicGUI)
	_WinAPI_DeleteObject($hGraphicGUI)
	GUIDelete($hGui)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath
EndFunc   ;==>_GDIPlus_Transparency

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_Text
; Description ...: Draw Text on picture
; Syntax.........: _GDIPlus_Text($iPath, $iString = '', $iX = 0, $iY = 0, $iFont = 'Arial', $iFontSize = 10, $iFontColor = 0xFFFFFFFF)
; Parameters ....: $iPath		- Path to the picture
;                  $iString		- String to draw
;                  $iX			- X position of the text
;                  $iY			- Y position of the text
;                  $iFont		- Font name
;                  $iFontSize	- Font size
;                  $iFontStyle	- Font Style
;~ 										0 - Normal weight or thickness of the typeface
;~ 										1 - Bold typeface
;~ 										2 - Italic typeface
;~ 										4 - Underline
;~ 										8 - Strikethrough
;                  $iFontColor	- Font Color
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
;; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_Text($iPath, $iString = '', $iX = 0, $iY = 0, $iFont = 'Arial', $iFontSize = 10, $iFontStyle = 0, $iFontColor = 0xFFFFFFFF, $iXOrigin = Default, $iYOrigin = Default)
;~ 	MsgBox(0,"DEBUG","_GDIPlus_Text");Debug
	Local $hImage, $ImageWidth, $ImageHeight, $hGui, $hGraphicGUI, $hBMPBuff, $hGraphic
	Local $hFamily, $hFont, $tLayout, $hFormat, $hBrush, $hPen, $aInfo, $aStringSize
	Local $MergedImageBackgroundColor = 0x00000000
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-TEXT_Temp.PNG"
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	$iPath = $sDrive & $sDir & $sFileName & ".png"
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$ImageWidth = _GDIPlus_ImageGetWidth($hImage)
	If $ImageWidth = 4294967295 Then $ImageWidth = 0 ;4294967295 en cas d'erreur.
	$ImageHeight = _GDIPlus_ImageGetHeight($hImage)
	$hGui = GUICreate("", $ImageWidth, $ImageHeight)
	$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGui) ;Draw to this graphics, $hGraphicGUI, to display on GUI
	$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($ImageWidth, $ImageHeight, $hGraphicGUI) ; $hBMPBuff is a bitmap in memory
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff) ; Draw to this graphics, $hGraphic, being the graphics of $hBMPBuff
	_GDIPlus_GraphicsClear($hGraphic, $MergedImageBackgroundColor) ;Fill the Graphic Background (0x00000000 for transparent background in .png files)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 0, 0)

	$iX = _GDIPlus_RelativePos($iX, $ImageWidth)
	$iY = _GDIPlus_RelativePos($iY, $ImageHeight)
	Switch $iX
		Case 'CENTER'
			$iX = Int($ImageWidth / 2)
		Case 'LEFT'
			$iX = 0
		Case 'RIGHT'
			$iX = $ImageWidth
	EndSwitch
	Switch $iY
		Case 'CENTER'
			$iY = Int($ImageHeight / 2)
		Case 'UP'
			$iY = 0
		Case 'DOWN'
			$iY = $ImageHeight
	EndSwitch
	$aStringSize = _GDIPlus_MeasureString($iString, $iFont, $iFontSize, $iFontStyle)
	$iXOrigin = _GDIPlus_RelativePos($iXOrigin, $ImageWidth)
	$iYOrigin = _GDIPlus_RelativePos($iYOrigin, $ImageWidth)
	Switch $iXOrigin
		Case 'CENTER'
			$iXOrigin = $aStringSize[0] / 2
		Case 'LEFT'
			$iXOrigin = 0
		Case 'RIGHT'
			$iXOrigin = $aStringSize[0]
		Case ''
			$iXOrigin = 0
	EndSwitch
	Switch $iYOrigin
		Case 'CENTER'
			$iYOrigin = $aStringSize[1] / 2
		Case 'UP'
			$iYOrigin = 0
		Case 'DOWN'
			$iYOrigin = $aStringSize[1]
		Case ''
			$iYOrigin = 0
	EndSwitch

	$hFamily = _GDIPlus_FontFamilyCreate($iFont)
	$hFont = _GDIPlus_FontCreate($hFamily, $iFontSize, $iFontStyle)
	$tLayout = _GDIPlus_RectFCreate($iX - $iXOrigin, $iY - $iYOrigin, $aStringSize[0], $aStringSize[1])
	$hFormat = _GDIPlus_StringFormatCreate() ; (2 - text are drawn vertically)
	$hBrush = _GDIPlus_BrushCreateSolid($iFontColor) ;0xFFFFFFFF) ; (0x00FFFFFF - fully transparent. Alpha channel zero)
	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $iString, $hFont, $tLayout, $hFormat)
	_GDIPlus_GraphicsDrawStringEx($hGraphic, $iString, $hFont, $aInfo[0], $hFormat, $hBrush)

	_GDIPlus_ImageSaveToFile($hBMPBuff, $iPath)

	_GDIPlus_FontDispose($hFont)
	_WinAPI_DeleteObject($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_WinAPI_DeleteObject($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_WinAPI_DeleteObject($hFormat)
	_GDIPlus_BrushDispose($hBrush)
	_WinAPI_DeleteObject($hBrush)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hGraphic)
	_GDIPlus_BitmapDispose($hBMPBuff)
	_WinAPI_DeleteObject($hBMPBuff)
	_GDIPlus_GraphicsDispose($hGraphicGUI)
	_WinAPI_DeleteObject($hGraphicGUI)
	GUIDelete($hGui)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath
EndFunc   ;==>_GDIPlus_Text

Func _GDIPlus_MeasureString($sString, $sFont = "Arial", $fSize = 10, $iStyle = 0, $bRound = True)
	Local $aSize[2]
	Local Const $hFamily = _GDIPlus_FontFamilyCreate($sFont)
	If Not $hFamily Then Return SetError(1, 0, $aSize)
	Local Const $hFormat = _GDIPlus_StringFormatCreate()
	Local Const $hFont = _GDIPlus_FontCreate($hFamily, $fSize, $iStyle)
	Local Const $tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	Local Const $hGraphic = _GDIPlus_GraphicsCreateFromHWND(0)
	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $sString, $hFont, $tLayout, $hFormat)
	$aSize[0] = $bRound ? Round($aInfo[0].Width, 0) : $aInfo[0].Width
	$aSize[1] = $bRound ? Round($aInfo[0].Height, 0) : $aInfo[0].Height
	_GDIPlus_FontDispose($hFont)
	_WinAPI_DeleteObject($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_WinAPI_DeleteObject($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_WinAPI_DeleteObject($hFormat)
	_GDIPlus_GraphicsDispose($hGraphic)
	Return $aSize
EndFunc   ;==>_GDIPlus_MeasureString

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_TransparencyZone
; Description ...: Apply transparency on a picture
; Syntax.........: _GDIPlus_TransparencyZone($iPath, $vTarget_Width, $vTarget_Height, $iTransLvl = 1, $iX = 0, $iY = 0, $iWidth = "", $iHeight = "")
; Parameters ....: $iPath			- Path to the picture
;                  $vTarget_Width	- Target Width
;                  $vTarget_Height	- Target Height
;                  $iTransLvl		- Value range from 0 (Zero for invisible) to 1.0 (fully opaque)
;                  $iX				- X position of the transparency zone
;                  $iY				- Y position of the transparency zone
;                  $iWidth			- Width of the transparency zone
;                  $iHeight			- Height of the transparency zone
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_TransparencyZone($iPath, $vTarget_Width, $vTarget_Height, $iTransLvl = 1, $iX = 0, $iY = 0, $iWidth = "", $iHeight = "")
	#forceref $iX, $iY, $iWidth, $iHeight
	Local $hImage, $ImageWidth, $ImageHeight, $hGui, $hGraphicGUI, $hBMPBuff, $hGraphic
	Local $MergedImageBackgroundColor = 0x00000000
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-TRANSZONE_Temp.PNG"
	$iPath_CutHole_Temp = $sDrive & $sDir & $sFileName & "-CutHole_Temp.PNG"
	$iPath_Crop_Temp = $sDrive & $sDir & $sFileName & "-CutCrop_Temp.PNG"
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	$iPath = $sDrive & $sDir & $sFileName & ".png"
	_GDIPlus_CalcPos($iX, $iY, $iWidth, $iHeight, $vTarget_Width, $vTarget_Height)
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$hNew_CutHole = _GDIPlus_ImageCutRectHole($hImage, $iX, $iY, $iWidth, $iHeight, $vTarget_Width, $vTarget_Height)
	If @error Then
		_LOG("Error _GDIPlus_ImageCutRectHole " & $iPath_Temp, 2, $iLOGPath)
		Return -1
	EndIf
	$hNew_Crop = _GDIPlus_ImageCrop($hImage, $iX, $iY, $iWidth, $iHeight, $vTarget_Width, $vTarget_Height)
	If @error Then
		_LOG("Error _GDIPlus_ImageCrop " & $iPath_Temp, 2, $iLOGPath)
		Return -1
	EndIf
	_GDIPlus_ImageSaveToFile($hNew_CutHole, $iPath_CutHole_Temp)
	_GDIPlus_ImageSaveToFile($hNew_Crop, $iPath_Crop_Temp)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_BitmapDispose($hNew_CutHole)
	_WinAPI_DeleteObject($hNew_CutHole)
	_GDIPlus_BitmapDispose($hNew_Crop)
	_WinAPI_DeleteObject($hNew_Crop)
	_GDIPlus_Shutdown()
	_GDIPlus_Transparency($iPath_Crop_Temp, $iTransLvl)
	_GDIPlus_Merge($iPath_CutHole_Temp, $iPath_Crop_Temp)
	FileCopy($iPath_CutHole_Temp, $iPath)
	FileDelete($iPath_CutHole_Temp)
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath
EndFunc   ;==>_GDIPlus_TransparencyZone

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_ImageCutRectHole
; Description ...: Cut a rectangle hole on a picture
; Syntax.........: _GDIPlus_ImageCutRectHole($hImage, $iX, $iY, $iWidthCut, $iHeightCut, $vTarget_Width, $vTarget_Height)
; Parameters ....: $hImage			- Handle to the picture
;                  $iX				- X position of the cut
;                  $iY				- Y position of the cut
;                  $iWidthCut		- Width of the cut
;                  $iHeightCut		- Height of the cut
;                  $vTarget_Width	- Target Width
;                  $vTarget_Height	- Target Height
; Return values .: Success      - Return Handle
;                  Failure      - -1
; Author ........: UEZ
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; https://www.autoitscript.com/forum/topic/146755-solvedlayer-mask-in-gdi/
; Example .......;
Func _GDIPlus_ImageCutRectHole($hImage, $iX, $iY, $iWidthCut, $iHeightCut, $vTarget_Width, $vTarget_Height)
	Local $hTexture = _GDIPlus_TextureCreate($hImage, 4)
	$hImage = _GDIPlus_BitmapCreateFromScan0($vTarget_Width, $vTarget_Height)
	Local $hGfxCtxt = _GDIPlus_ImageGetGraphicsContext($hImage)
	_GDIPlus_GraphicsSetSmoothingMode($hGfxCtxt, 2)
	_GDIPlus_GraphicsSetPixelOffsetMode($hGfxCtxt, 2)
	_GDIPlus_GraphicsFillRect($hGfxCtxt, 0, 0, $iX, $vTarget_Height, $hTexture)
	_GDIPlus_GraphicsFillRect($hGfxCtxt, $iX + $iWidthCut, 0, $vTarget_Width - ($iX + $iWidthCut), $vTarget_Height, $hTexture)
	_GDIPlus_GraphicsFillRect($hGfxCtxt, $iX, 0, $iWidthCut, $iY, $hTexture)
	_GDIPlus_GraphicsFillRect($hGfxCtxt, $iX, $iY + $iHeightCut, $iWidthCut, $vTarget_Height - ($iY + $iHeightCut), $hTexture)
	_GDIPlus_BrushDispose($hTexture)
	_WinAPI_DeleteObject($hTexture)
	_GDIPlus_GraphicsDispose($hGfxCtxt)
	_WinAPI_DeleteObject($hGfxCtxt)
	Return $hImage
EndFunc   ;==>_GDIPlus_ImageCutRectHole

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_ImageCrop
; Description ...: Crop a picture
; Syntax.........: _GDIPlus_ImageCrop($hImage, $iX, $iY, $iWidthCut, $iHeightCut, $vTarget_Width, $vTarget_Height)
; Parameters ....: $hImage			- Handle to the picture
;                  $iX				- X position of the crop
;                  $iY				- Y position of the crop
;                  $iWidthCut		- Width of the crop
;                  $iHeightCut		- Height of the crop
;                  $vTarget_Width	- Target Width
;                  $vTarget_Height	- Target Height
; Return values .: Success      - Return Handle
;                  Failure      - -1
; Author ........: UEZ
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; https://www.autoitscript.com/forum/topic/146755-solvedlayer-mask-in-gdi/
; Example .......;
Func _GDIPlus_ImageCrop($hImage, $iX, $iY, $iWidthCut, $iHeightCut, $vTarget_Width, $vTarget_Height)
	Local $hTexture = _GDIPlus_TextureCreate($hImage, 4)
	$hImage = _GDIPlus_BitmapCreateFromScan0($vTarget_Width, $vTarget_Height)
	Local $hGfxCtxt = _GDIPlus_ImageGetGraphicsContext($hImage)
	_GDIPlus_GraphicsSetSmoothingMode($hGfxCtxt, 2)
	_GDIPlus_GraphicsSetPixelOffsetMode($hGfxCtxt, 2)
	_GDIPlus_GraphicsFillRect($hGfxCtxt, $iX, $iY, $iWidthCut, $iHeightCut, $hTexture)
	_GDIPlus_BrushDispose($hTexture)
	_WinAPI_DeleteObject($hTexture)
	_GDIPlus_GraphicsDispose($hGfxCtxt)
	_WinAPI_DeleteObject($hGfxCtxt)
	Return $hImage
EndFunc   ;==>_GDIPlus_ImageCrop

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_CalcPos
; Description ...: Calculate Relative and tagged position and size
; Syntax.........: _GDIPlus_CalcPos(ByRef $iX, ByRef $iY, ByRef $iWidth, ByRef $iHeight, $vTarget_Width, $vTarget_Height)
; Parameters ....: $iX				- X position to calculate
;                  $iY				- Y position to calculate
;                  $iWidth			- Width
;                  $iHeight			- Height
;                  $vTarget_Width	- Target Width
;                  $vTarget_Height	- Target Height
; Return values .: Success      - Return position and size ByRef
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _GDIPlus_CalcPos(ByRef $iX, ByRef $iY, ByRef $iWidth, ByRef $iHeight, $vTarget_Width, $vTarget_Height)
	$iWidth = _GDIPlus_RelativePos($iWidth, $vTarget_Width)
	If $iWidth = "" Then $iWidth = $vTarget_Width
	$iHeight = _GDIPlus_RelativePos($iHeight, $vTarget_Height)
	If $iHeight = "" Then $iHeight = $vTarget_Height
	$iX = _GDIPlus_CalcPosX($iX, $iWidth, $vTarget_Width)
	$iY = _GDIPlus_CalcPosY($iY, $iHeight, $vTarget_Height)
EndFunc   ;==>_GDIPlus_CalcPos

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_CalcPosX
; Description ...: Calculate Relative and tagged X position
; Syntax.........: _GDIPlus_CalcPosX($iX, $iWidth, $vTarget_Width)
; Parameters ....: $iX				- X position to calculate
;                  $iWidth			- Width
;                  $vTarget_Width	- Target Width
; Return values .: Success      - Return $iX
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _GDIPlus_CalcPosX($iX, $iWidth, $vTarget_Width)
	$iX = _GDIPlus_RelativePos($iX, $vTarget_Width)
	Switch $iX
		Case 'CENTER'
			$iX = ($vTarget_Width / 2) - ($iWidth / 2)
		Case 'LEFT'
			$iX = 0
		Case 'RIGHT'
			$iX = $vTarget_Width - $iWidth
	EndSwitch
	Return Int($iX)
EndFunc   ;==>_GDIPlus_CalcPosX

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_CalcPosY
; Description ...: Calculate Relative and tagged X position
; Syntax.........: _GDIPlus_CalcPosY($iY, $iHeight, $vTarget_Height)
; Parameters ....: $iY				- Y position to calculate
;                  $iHeight			- Height
;                  $vTarget_Height	- Target Height
; Return values .: Success      - Return $iY
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
Func _GDIPlus_CalcPosY($iY, $iHeight, $vTarget_Height)
	$iY = _GDIPlus_RelativePos($iY, $vTarget_Height)
	Switch $iY
		Case 'CENTER'
			$iY = ($vTarget_Height / 2) - ($iHeight / 2)
		Case 'UP'
			$iY = 0
		Case 'DOWN'
			$iY = $vTarget_Height - $iHeight
	EndSwitch
	Return Int($iY)
EndFunc   ;==>_GDIPlus_CalcPosY

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_Merge($iPath1, $iPath2)
; Description ...: Merge 2 pictures
; Syntax.........: _GDIPlus_Merge($iPath1, $iPath2)
; Parameters ....: $iPath1		- First image path
;                  $iPath1		- Second image path
; Return values .: Success      - Return the path of the finale picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......: Delete $iPath2 after merging
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_Merge($iPath1, $iPath2)
;~ 	MsgBox(0,"DEBUG","_GDIPlus_Merge");Debug
	Local $hGui, $hGraphicGUI, $hBMPBuff, $hGraphic, $ImageWidth, $ImageHeight
	Local $MergedImageBackgroundColor = 0x00000000
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp
	_PathSplit($iPath1, $sDrive, $sDir, $sFileName, $iExtension)
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-MER_Temp.PNG"

	If _MakeTEMPFile($iPath1, $iPath_Temp) = -1 Then
		_LOG("Error Merging " & $iPath1 & " and " & $iPath2, 2, $iLOGPath)
		Return -1
	EndIf

	$iPath1 = $sDrive & $sDir & $sFileName & ".png"

	_GDIPlus_Startup()
	$hImage1 = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	$hImage2 = _GDIPlus_ImageLoadFromFile($iPath2)
	$ImageWidth = _GDIPlus_ImageGetWidth($hImage1)
	If $ImageWidth = 4294967295 Then $ImageWidth = 0 ;4294967295 en cas d'erreur.
	$ImageHeight = _GDIPlus_ImageGetHeight($hImage1)
	$hGui = GUICreate("", $ImageWidth, $ImageHeight)
	$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGui) ;Draw to this graphics, $hGraphicGUI, to display on GUI
	$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($ImageWidth, $ImageHeight, $hGraphicGUI) ; $hBMPBuff is a bitmap in memory
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff) ; Draw to this graphics, $hGraphic, being the graphics of $hBMPBuff
	_GDIPlus_GraphicsClear($hGraphic, $MergedImageBackgroundColor) ;Fill the Graphic Background (0x00000000 for transparent background in .png files)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage1, 0, 0)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage2, 0, 0)

	_LOG("Merging " & $iPath2 & " on " & $iPath_Temp, 0, $iLOGPath) ; Debug
	_GDIPlus_ImageSaveToFile($hBMPBuff, $iPath1)

	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hGraphic)
	_GDIPlus_BitmapDispose($hBMPBuff)
	_WinAPI_DeleteObject($hBMPBuff)
	_GDIPlus_GraphicsDispose($hGraphicGUI)
	_WinAPI_DeleteObject($hGraphicGUI)
	GUIDelete($hGui)
	_GDIPlus_ImageDispose($hImage2)
	_WinAPI_DeleteObject($hImage2)
	_GDIPlus_ImageDispose($hImage1)
	_WinAPI_DeleteObject($hImage1)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	If Not FileDelete($iPath2) Then
		_LOG("Error deleting " & $iPath2, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath1
EndFunc   ;==>_GDIPlus_Merge

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_GraphicsDrawImageRectRectTrans
; Description ...: Draw an Image object with transparency
; Syntax.........: _GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, $iSrcX, $iSrcY, [$iSrcWidth, _
;                                   [$iSrcHeight, [$iDstX, [$iDstY, [$iDstWidth, [$iDstHeight[, [$iUnit = 2]]]]]]])
; Parameters ....: $hGraphics   - Handle to a Graphics object
;                  $hImage      - Handle to an Image object
;                  $iSrcX       - The X coordinate of the upper left corner of the source image
;                  $iSrcY       - The Y coordinate of the upper left corner of the source image
;                  $iSrcWidth   - Width of the source image
;                  $iSrcHeight  - Height of the source image
;                  $iDstX       - The X coordinate of the upper left corner of the destination image
;                  $iDstY       - The Y coordinate of the upper left corner of the destination image
;                  $iDstWidth   - Width of the destination image
;                  $iDstHeight  - Height of the destination image
;                  $iUnit       - Specifies the unit of measure for the image
;                  $nTrans      - Value range from 0 (Zero for invisible) to 1.0 (fully opaque)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Siao
; Modified.......: Malkey
; Remarks .......:
; Related .......:
; Link ..........; http://www.autoitscript.com/forum/index.php?s=&showtopic=70573&view=findpost&p=517195
; Example .......; Yes
Func _GDIPlus_GraphicsDrawImageRectRectTrans($hGraphics, $hImage, $iSrcX, $iSrcY, $iSrcWidth = "", $iSrcHeight = "", _
		$iDstX = "", $iDstY = "", $iDstWidth = "", $iDstHeight = "", $iUnit = 2, $nTrans = 1)
	Local $tColorMatrix, $hImgAttrib, $iW = _GDIPlus_ImageGetWidth($hImage), $iH = _GDIPlus_ImageGetHeight($hImage)
	If $iSrcWidth = 0 Or $iSrcWidth = "" Then $iSrcWidth = $iW
	If $iSrcHeight = 0 Or $iSrcHeight = "" Then $iSrcHeight = $iH
	If $iDstX = "" Then $iDstX = $iSrcX
	If $iDstY = "" Then $iDstY = $iSrcY
	If $iDstWidth = "" Then $iDstWidth = $iSrcWidth
	If $iDstHeight = "" Then $iDstHeight = $iSrcHeight
	If $iUnit = "" Then $iUnit = 2
	;;create color matrix data
	$tColorMatrix = DllStructCreate("float[5];float[5];float[5];float[5];float[5]")
	;blending values:
	Local $x = DllStructSetData($tColorMatrix, 1, 1, 1) * DllStructSetData($tColorMatrix, 2, 1, 2) * DllStructSetData($tColorMatrix, 3, 1, 3) * _
			DllStructSetData($tColorMatrix, 4, $nTrans, 4) * DllStructSetData($tColorMatrix, 5, 1, 5)
;~ 	$x = $x
	;;create an image attributes object and update its color matrix
	$hImgAttrib = _GDIPlus_ImageAttributesCreate()
	_GDIPlus_ImageAttributesSetColorMatrix($hImgAttrib, 1, 1, DllStructGetPtr($tColorMatrix))
	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, $iSrcX, $iSrcY, $iSrcWidth, $iSrcHeight, $iDstX, $iDstY, $iDstWidth, $iDstHeight, $hImgAttrib, $iUnit)
	;;clean up
	_GDIPlus_ImageAttributesDispose($hImgAttrib)
	_WinAPI_DeleteObject($hImgAttrib)
	Return
EndFunc   ;==>_GDIPlus_GraphicsDrawImageRectRectTrans

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_Imaging
; Description ...: Prepare a picture
; Syntax.........: _GDIPlus_Imaging($iPath, $aPicParameters, $vTarget_Width, $vTarget_Height, $vTarget_Maximize = 'no')
; Parameters ....: $iPath			- Path to the picture
;                  $aPicParameters	- Position Parameter
;                  $vTarget_Width	- Target Width
;                  $vTarget_Height	- Target Height
;                  $vTarget_Maximize- Maximize the picture (yes or no)
; Return values .: Success      - Return the Path of the Picture
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......: 	$aPicParameters[0] = Target_Width
; 					$aPicParameters[1] = Target_Height
;				 	$aPicParameters[2] = Target_TopLeftX
;				 	$aPicParameters[3] = Target_TopLeftY
;				 	$aPicParameters[4] = Target_TopRightX
;				 	$aPicParameters[5] = Target_TopRightY
;				 	$aPicParameters[6] = Target_BottomLeftX
;				 	$aPicParameters[7] = Target_BottomLeftY
;				 	$aPicParameters[8] = Target_Maximize
;					$aPicParameters[9] = Target_OriginX
;					$aPicParameters[10] = Target_OriginY
;					$aPicParameters[11] = Target_BottomRightX
;					$aPicParameters[12] = Target_BottomRightY
;					$aPicParameters[13] = Target_OriginPicX
;					$aPicParameters[14] = Target_OriginPicY
; Related .......:
; Link ..........;
; Example .......; No
Func _GDIPlus_Imaging($iPath, $aPicParameters, $vTarget_Width, $vTarget_Height)
	Local $sDrive, $sDir, $sFileName, $iExtension, $iPath_Temp, $vNo4thPoint = 0
	_PathSplit($iPath, $sDrive, $sDir, $sFileName, $iExtension)
	$aPicParameters[8] = StringUpper($aPicParameters[8])
	$iPath_Temp = $sDrive & $sDir & $sFileName & "-IMAGING_Temp" & $iExtension
	Local $hImage, $hGui, $hGraphicGUI, $hBMPBuff, $hGraphic
	Local $MergedImageBackgroundColor = 0x00000000
	Local $iWidth = _GDIPlus_RelativePos($aPicParameters[0], $vTarget_Width)
	Local $iHeight = _GDIPlus_RelativePos($aPicParameters[1], $vTarget_Height)
	If $aPicParameters[8] = 'YES' Then _GDIPlus_ResizeMax($iPath, $iWidth, $iHeight)
	If _MakeTEMPFile($iPath, $iPath_Temp) = -1 Then Return -1
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile($iPath_Temp)
	If $iWidth <= 0 Or $aPicParameters[8] = 'YES' Then $iWidth = _GDIPlus_ImageGetWidth($hImage)
	If $iHeight <= 0 Or $aPicParameters[8] = 'YES' Then $iHeight = _GDIPlus_ImageGetHeight($hImage)
	$hGui = GUICreate("", $vTarget_Width, $vTarget_Height)
	$hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGui) ;Draw to this graphics, $hGraphicGUI, to display on GUI
	$hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($vTarget_Width, $vTarget_Height, $hGraphicGUI) ; $hBMPBuff is a bitmap in memory
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff) ; Draw to this graphics, $hGraphic, being the graphics of $hBMPBuff
	_GDIPlus_GraphicsClear($hGraphic, $MergedImageBackgroundColor) ; Fill the Graphic Background (0x00000000 for transparent background in .png files)
	Local $Image_C1X = _GDIPlus_RelativePos($aPicParameters[2], $vTarget_Width)
	Local $Image_C1Y = _GDIPlus_RelativePos($aPicParameters[3], $vTarget_Height)
	Local $Image_C2X = _GDIPlus_RelativePos($aPicParameters[4], $vTarget_Width)
	Local $Image_C2Y = _GDIPlus_RelativePos($aPicParameters[5], $vTarget_Height)
	Local $Image_C3X = _GDIPlus_RelativePos($aPicParameters[6], $vTarget_Width)
	Local $Image_C3Y = _GDIPlus_RelativePos($aPicParameters[7], $vTarget_Height)
;~ 	Local $Image_C4X = _GDIPlus_RelativePos($aPicParameters[11], $vTarget_Width)
;~ 	Local $Image_C4Y = _GDIPlus_RelativePos($aPicParameters[12], $vTarget_Height)
	Local $Image_OriginX = _GDIPlus_RelativePos($aPicParameters[13], $iWidth)
	Local $Image_OriginY = _GDIPlus_RelativePos($aPicParameters[14], $iHeight)
	Switch $Image_OriginX
		Case 'CENTER'
			$Image_OriginX = $iWidth / 2
		Case 'LEFT'
			$Image_OriginX = 0
		Case 'RIGHT'
			$Image_OriginX = $iWidth
		Case ''
			$Image_OriginX = 0
	EndSwitch
	Switch $Image_OriginY
		Case 'CENTER'
			$Image_OriginY = $iHeight / 2
		Case 'UP'
			$Image_OriginY = 0
		Case 'DOWN'
			$Image_OriginY = $iHeight
		Case ''
			$Image_OriginY = 0
	EndSwitch
	Switch $Image_C1X
		Case 'CENTER'
			$Image_C1X = Int($vTarget_Width / 2)
		Case 'LEFT'
			$Image_C1X = 0
		Case 'RIGHT'
			$Image_C1X = $vTarget_Width
	EndSwitch
	Switch $Image_C1Y
		Case 'CENTER'
			$Image_C1Y = Int($vTarget_Height / 2)
		Case 'UP'
			$Image_C1Y = 0
		Case 'DOWN'
			$Image_C1Y = $vTarget_Height
	EndSwitch
	Switch $Image_C2X
		Case 'CENTER'
			$Image_C2X = Int($vTarget_Width / 2) + $iWidth
		Case 'LEFT'
			$Image_C2X = $iWidth
		Case 'RIGHT'
			$Image_C2X = $vTarget_Width + $iWidth
		Case ''
			$Image_C2X = $Image_C1X + $iWidth
	EndSwitch
	Switch $Image_C2Y
		Case 'CENTER'
			$Image_C2Y = Int($vTarget_Height / 2)
		Case 'UP'
			$Image_C2Y = 0
		Case 'DOWN'
			$Image_C2Y = $vTarget_Height
		Case ''
			$Image_C2Y = $Image_C1Y
	EndSwitch
	Switch $Image_C3X
		Case 'CENTER'
			$Image_C3X = Int($vTarget_Width / 2)
		Case 'LEFT'
			$Image_C3X = 0
		Case 'RIGHT'
			$Image_C3X = $vTarget_Width
		Case ''
			$Image_C3X = $Image_C1X
	EndSwitch
	Switch $Image_C3Y
		Case 'CENTER'
			$Image_C3Y = Int($vTarget_Height / 2) + $iHeight
		Case 'UP'
			$Image_C3Y = 0 + $iHeight
		Case 'DOWN'
			$Image_C3Y = $vTarget_Height + $iHeight
		Case ''
			$Image_C3Y = $Image_C1Y + $iHeight
	EndSwitch
;~ 	Switch $Image_C4X
;~ 		Case 'CENTER'
;~ 			$Image_C4X = Int($vTarget_Width / 2) + $iWidth
;~ 		Case 'LEFT'
;~ 			$Image_C4X = $iWidth
;~ 		Case 'RIGHT'
;~ 			$Image_C4X = $vTarget_Width + $iWidth
;~ 		Case ''
;~ 			$vNo4thPoint = 1
;~ 			$Image_C4X = $Image_C1X + $iWidth
;~ 	EndSwitch
;~ 	Switch $Image_C4Y
;~ 		Case 'CENTER'
;~ 			$Image_C4Y = Int($vTarget_Height / 2) + $iHeight
;~ 		Case 'UP'
;~ 			$Image_C4Y = 0 + $iHeight
;~ 		Case 'DOWN'
;~ 			$Image_C4Y = $vTarget_Height + $iHeight
;~ 		Case ''
;~ 			$vNo4thPoint = 1
;~ 			$Image_C4Y = $Image_C1Y + $iHeight
;~ 	EndSwitch


	$Image_C1X = $Image_C1X + _GDIPlus_RelativePos($aPicParameters[9], $vTarget_Width) - $Image_OriginX
	$Image_C1Y = $Image_C1Y + _GDIPlus_RelativePos($aPicParameters[10], $vTarget_Height) - $Image_OriginY
	$Image_C2X = $Image_C2X + _GDIPlus_RelativePos($aPicParameters[9], $vTarget_Width) - $Image_OriginX
	$Image_C2Y = $Image_C2Y + _GDIPlus_RelativePos($aPicParameters[10], $vTarget_Height) - $Image_OriginY
	$Image_C3X = $Image_C3X + _GDIPlus_RelativePos($aPicParameters[9], $vTarget_Width) - $Image_OriginX
	$Image_C3Y = $Image_C3Y + _GDIPlus_RelativePos($aPicParameters[10], $vTarget_Height) - $Image_OriginY
;~ 	$Image_C4X = $Image_C4X + _GDIPlus_RelativePos($aPicParameters[9], $vTarget_Width) - $Image_OriginX
;~ 	$Image_C4Y = $Image_C4Y + _GDIPlus_RelativePos($aPicParameters[10], $vTarget_Height) - $Image_OriginY

	_LOG("$Image_C1X = " & $Image_C1X, 2, $iLOGPath)
	_LOG("$Image_C1Y = " & $Image_C1Y, 2, $iLOGPath)
	_LOG("$Image_C2X = " & $Image_C2X, 2, $iLOGPath)
	_LOG("$Image_C2Y = " & $Image_C2Y, 2, $iLOGPath)
	_LOG("$Image_C3X = " & $Image_C3X, 2, $iLOGPath)
	_LOG("$Image_C3Y = " & $Image_C3Y, 2, $iLOGPath)
;~ 	_LOG("$Image_C4X = " & $Image_C4X, 2, $iLOGPath)
;~ 	_LOG("$Image_C4Y = " & $Image_C4Y, 2, $iLOGPath)

;~ 	If $vNo4thPoint = 1 Then
	_LOG("_GDIPlus_DrawImagePoints", 2, $iLOGPath)
	_GDIPlus_DrawImagePoints($hGraphic, $hImage, $Image_C1X, $Image_C1Y, $Image_C2X, $Image_C2Y, $Image_C3X, $Image_C3Y)
;~ 	Else
;~ 		_LOG("_GDIPlus_GraphicsDrawImage_4Points", 2, $iLOGPath)
;~ 		_GDIPlus_GraphicsDrawImage_4Points($hGraphic, $hImage, $Image_C1X, $Image_C1Y, $Image_C2X, $Image_C2Y, $Image_C3X, $Image_C3Y, $Image_C4X, $Image_C4Y)
;~ 	EndIf
	_GDIPlus_ImageSaveToFile($hBMPBuff, $iPath)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hGraphic)
	_GDIPlus_BitmapDispose($hBMPBuff)
	_WinAPI_DeleteObject($hBMPBuff)
	_GDIPlus_GraphicsDispose($hGraphicGUI)
	_WinAPI_DeleteObject($hGraphicGUI)
	GUIDelete($hGui)
	_GDIPlus_ImageDispose($hImage)
	_WinAPI_DeleteObject($hImage)
	_GDIPlus_Shutdown()
	If Not FileDelete($iPath_Temp) Then
		_LOG("Error deleting " & $iPath_Temp, 2, $iLOGPath)
;~ 		Return -1
	EndIf
	Return $iPath
EndFunc   ;==>_GDIPlus_Imaging

; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_GraphicsDrawImage_4Points
; Description ...: Draw Pic with 4 points distortion
; Syntax.........: _GDIPlus_GraphicsDrawImage_4Points($hGraphics, $hImage, $X1, $Y1, $X2, $Y2, $X3, $Y3, $X4, $Y4, $fPrecision = 0.25)
; Parameters ....:
; Return values .:
; Author ........: eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; https://www.autoitscript.com/forum/topic/123623-gdi-image-question/#comment-860805
Func _GDIPlus_GraphicsDrawImage_4Points($hGraphics, $hImage, $X1, $Y1, $X2, $Y2, $X3, $Y3, $X4, $Y4, $fPrecision = 0.25)
	;by eukalyptus
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipCreatePath", "int", 0, "int*", 0)
	If @error Or Not IsArray($aResult) Then Return SetError(1, 1, False)
	Local $hPath = $aResult[2]

	Local $iW = _GDIPlus_ImageGetWidth($hImage)
	Local $iH = _GDIPlus_ImageGetHeight($hImage)

	If $fPrecision <= 0 Then $fPrecision = 0.01
	If $fPrecision > 1 Then $fPrecision = 1

	Local $iTX = Ceiling($iW * $fPrecision)
	Local $iTY = Ceiling($iH * $fPrecision)
	Local $iCnt = ($iTX + 1) * ($iTY + 1)
	Local $x, $Y

	Local $tPoints = DllStructCreate("float[" & $iCnt * 2 & "]")
	Local $I
	For $Y = 0 To $iTY
		For $x = 0 To $iTX
			$I = ($Y * ($iTX + 1) + $x) * 2
			DllStructSetData($tPoints, 1, $x * $iW / $iTX, $I + 1)
			DllStructSetData($tPoints, 1, $Y * $iH / $iTY, $I + 2)
		Next
	Next

	$aResult = DllCall($__g_hGDIPDll, "uint", "GdipAddPathPolygon", "hwnd", $hPath, "ptr", DllStructGetPtr($tPoints), "int", $iCnt)
	If @error Or Not IsArray($aResult) Then Return SetError(1, 2, False)

	Local $tWarp = DllStructCreate("float[8]")
	DllStructSetData($tWarp, 1, $X1, 1)
	DllStructSetData($tWarp, 1, $Y1, 2)
	DllStructSetData($tWarp, 1, $X2, 3)
	DllStructSetData($tWarp, 1, $Y2, 4)
	DllStructSetData($tWarp, 1, $X3, 5)
	DllStructSetData($tWarp, 1, $Y3, 6)
	DllStructSetData($tWarp, 1, $X4, 7)
	DllStructSetData($tWarp, 1, $Y4, 8)

	$aResult = DllCall($__g_hGDIPDll, "uint", "GdipWarpPath", "hwnd", $hPath, "hwnd", 0, "ptr", DllStructGetPtr($tWarp), "int", 4, "float", 0, "float", 0, "float", $iW, "float", $iH, "int", 0, "float", 0)
	If @error Or Not IsArray($aResult) Then Return SetError(1, 3, False)

	$aResult = DllCall($__g_hGDIPDll, "uint", "GdipGetPathPoints", "hwnd", $hPath, "ptr", DllStructGetPtr($tPoints), "int", $iCnt)
	If @error Or Not IsArray($aResult) Then Return SetError(1, 4, False)

	Local $tRectF = DllStructCreate("float X;float Y;float Width;float Height")
	$aResult = DllCall($__g_hGDIPDll, "uint", "GdipGetPathWorldBounds", "hwnd", $hPath, "ptr", DllStructGetPtr($tRectF), "hwnd", 0, "hwnd", 0)
	If @error Or Not IsArray($aResult) Then Return SetError(1, 5, False)

	DllCall($__g_hGDIPDll, "uint", "GdipDeletePath", "hwnd", $hPath)

	Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics(DllStructGetData($tRectF, 1) + DllStructGetData($tRectF, 3), DllStructGetData($tRectF, 2) + DllStructGetData($tRectF, 4), $hGraphics)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)

	Local $tDraw = DllStructCreate("float[6]")
	Local $pDraw = DllStructGetPtr($tDraw)
	Local $W = $iW / $iTX
	Local $H = $iH / $iTY
	Local $iO = ($iTX + 1) * 2
	Local $fX1, $fY1, $fX2, $fY2, $fX3, $fY3, $fSX, $fSY

	For $Y = 0 To $iTY - 1
		For $x = 0 To $iTX - 1
			$I = ($Y * ($iTX + 1) + $x) * 2
			$fX1 = DllStructGetData($tPoints, 1, $I + 1)
			$fY1 = DllStructGetData($tPoints, 1, $I + 2)

			Switch $x
				Case $iTX - 1
					$fX2 = DllStructGetData($tPoints, 1, $I + 3)
					$fY2 = DllStructGetData($tPoints, 1, $I + 4)
					$fSX = 1
				Case Else
					$fX2 = DllStructGetData($tPoints, 1, $I + 5)
					$fY2 = DllStructGetData($tPoints, 1, $I + 6)
					$fSX = 2
			EndSwitch

			Switch $Y
				Case $iTY - 1
					$fX3 = DllStructGetData($tPoints, 1, $I + 1 + $iO)
					$fY3 = DllStructGetData($tPoints, 1, $I + 2 + $iO)
					$fSY = 1
				Case Else
					$fX3 = DllStructGetData($tPoints, 1, $I + 1 + $iO * 2)
					$fY3 = DllStructGetData($tPoints, 1, $I + 2 + $iO * 2)
					$fSY = 2
			EndSwitch

			DllStructSetData($tDraw, 1, $fX1, 1)
			DllStructSetData($tDraw, 1, $fY1, 2)
			DllStructSetData($tDraw, 1, $fX2, 3)
			DllStructSetData($tDraw, 1, $fY2, 4)
			DllStructSetData($tDraw, 1, $fX3, 5)
			DllStructSetData($tDraw, 1, $fY3, 6)

			DllCall($__g_hGDIPDll, "uint", "GdipDrawImagePointsRect", "hwnd", $hContext, "hwnd", $hImage, "ptr", $pDraw, "int", 3, "float", $x * $W, "float", $Y * $H, "float", $W * $fSX, "float", $H * $fSY, "int", 2, "hwnd", 0, "ptr", 0, "ptr", 0)
		Next
	Next

	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)
	_GDIPlus_BitmapDispose($hBitmap)
EndFunc   ;==>_GDIPlus_GraphicsDrawImage_4Points
#EndRegion GDI Function

#Region XML Function

; #FUNCTION# ===================================================================================================
; Name...........: _XML_Open
; Description ...: Open an XML Object
; Syntax.........: _XML_Open($iXMLPath)
; Parameters ....: $iXMLPath	- Path to the XML File
; Return values .: Success      - Object contening the XML File
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_Open($iXMLPath)
	Local $oXMLDoc = _XML_CreateDOMDocument()
	_XML_Load($oXMLDoc, $iXMLPath)
	If @error Then
		_LOG('_XML_Load @error:' & @CRLF & XML_My_ErrorParser(@error), 2, $iLOGPath)
		Return -1
	EndIf
	_XML_TIDY($oXMLDoc)
	If @error Then
		_LOG('_XML_TIDY @error:' & @CRLF & XML_My_ErrorParser(@error), 2, $iLOGPath)
		Return -1
	EndIf
;~ 	_LOG($iXMLPath & " Open", 3, $iLOGPath)
	Return $oXMLDoc
EndFunc   ;==>_XML_Open

; #FUNCTION# ===================================================================================================
; Name...........: _XML_Read
; Description ...: Read Data in XML File or XML Object
; Syntax.........: _XML_Read($iXpath, [$iXMLType=0], [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the value to read
;                  $iXMLType	- Type of Value (0 = Node Value, 1 = Attribute Value)
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - First Value
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_Read($iXpath, $iXMLType = 0, $iXMLPath = "", $oXMLDoc = "")
	Local $iXMLValue = -1, $oNode, $iXpathSplit, $iXMLAttributeName
	If $iXMLPath = "" And $oXMLDoc = "" Then Return -1
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then
			_LOG('_XML_Open ERROR (' & $iXpath & ')', 2, $iLOGPath)
			Return -1
		EndIf
	EndIf

	Switch $iXMLType
		Case 0
			If _XML_NodeExists($oXMLDoc, $iXpath) <> $XML_RET_SUCCESS Then
;~ 				_LOG('_XML_NodeExists ERROR (' & $iXpath & " doesn't exist)", 3, $iLOGPath)
				Return ""
			EndIf
			$iXMLValue = _XML_GetValue($oXMLDoc, $iXpath)
			If @error Then
				If @error = 21 Then Return ""
				_LOG('_XML_GetValue ERROR (' & $iXpath & ')', 2, $iLOGPath)
				_LOG('_XML_GetValue @error(' & @error & ') :' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
				Return -1
			EndIf
			If IsArray($iXMLValue) And UBound($iXMLValue) - 1 > 0 Then
				_LOG('...Value..._XML_GetValue (' & $iXpath & ') = ' & $iXMLValue[1], 3, $iLOGPath)
				Return $iXMLValue[1]
			Else
				_LOG('_XML_GetValue (' & $iXpath & ') is not an Array', 2, $iLOGPath)
				Return -1
			EndIf
		Case 1
			$iXpathSplit = StringSplit($iXpath, "/")
			$iXMLAttributeName = $iXpathSplit[UBound($iXpathSplit) - 1]
			$iXpath = StringTrimRight($iXpath, StringLen($iXMLAttributeName) + 1)
			$oNode = _XML_SelectSingleNode($oXMLDoc, $iXpath)
			If @error Then
				_LOG('_XML_SelectSingleNode ERROR (' & $iXpath & ')', 2, $iLOGPath)
				_LOG('_XML_SelectSingleNode @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
				Return -1
			EndIf
			$iXMLValue = _XML_GetNodeAttributeValue($oNode, $iXMLAttributeName)
			If @error Then
				_LOG('_XML_GetNodeAttributeValue ERROR (' & $iXpath & ')', 2, $iLOGPath)
				_LOG('_XML_GetNodeAttributeValue @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
				Return -1
			EndIf
			_LOG('...Attribut..._XML_GetValue (' & $iXpath & ') = ' & $iXMLValue, 3, $iLOGPath)
			Return $iXMLValue
		Case Else
			Return -2
	EndSwitch

	Return -1
EndFunc   ;==>_XML_Read

; #FUNCTION# ===================================================================================================
; Name...........: _XML_Replace
; Description ...: replace Data in XML File or XML Object
; Syntax.........: _XML_Replace($iXpath, $iValue, [$iXMLType=0], [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the value to replace
;~ 				   $iValue		- Value to replace
;                  $iXMLType	- Type of Value (0 = Node Value, 1 = Attribute Value)
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - 1
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_Replace($iXpath, $iValue = " ", $iXMLType = 0, $iXMLPath = "", $oXMLDoc = "")
	Local $iXMLValue = -1, $oNode, $iXpathSplit, $iXMLAttributeName
	If $iXMLPath = "" And $oXMLDoc = "" Then
		_LOG('_XML_Replace Error : Need an Handle or Path', 2, $iLOGPath)
		Return -1
	EndIf
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then Return -1
	EndIf

	Switch $iXMLType
		Case 0
			$iXMLValue = _XML_UpdateField($oXMLDoc, $iXpath, $iValue)
			If @error Then
				_LOG('_XML_UpdateField @error:' & @CRLF & XML_My_ErrorParser(@error), 2, $iLOGPath)
				Return -1
			EndIf
			_XML_TIDY($oXMLDoc)
			_LOG('_XML_UpdateField (' & $iXpath & ') = ' & $iValue, 1, $iLOGPath)
			Return 1
		Case 1
			$iXpathSplit = StringSplit($iXpath, "/")
			$iXMLAttributeName = $iXpathSplit[UBound($iXpathSplit) - 1]
			$iXpath = StringTrimRight($iXpath, StringLen($iXMLAttributeName) + 1)
			_XML_SetAttrib($oXMLDoc, $iXpath, $iXMLAttributeName, $iValue)
			If @error Then
				_LOG('_XML_SelectSingleNode @error:' & @CRLF & XML_My_ErrorParser(@error), 2, $iLOGPath)
				Return -1
			EndIf
			_XML_TIDY($oXMLDoc)
			_LOG('_XML_UpdateField (' & $iXpath & ') = ' & $iValue, 1, $iLOGPath)
			Return 1
		Case Else
			_LOG('_XML_Replace : $iXMLType Unknown', 2, $iLOGPath)
			Return -1
	EndSwitch

	Return -1
EndFunc   ;==>_XML_Replace

; #FUNCTION# ===================================================================================================
; Name...........: _XML_ListValue
; Description ...: List Data in XML File or XML Object
; Syntax.........: _XML_ListValue($iXpath, [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the values to read
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - Array with all the data ([0] = Nb of Values)
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......: No attribute
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_ListValue($iXpath, $iXMLPath = "", $oXMLDoc = "")
	Local $iXMLValue = -1
	If $iXMLPath = "" And $oXMLDoc = "" Then Return -1
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then Return -1
	EndIf

	$iXMLValue = _XML_GetValue($oXMLDoc, $iXpath)
	If @error Then
		_LOG('_XML_GetValue ERROR (' & $iXpath & ')', 2, $iLOGPath)
		_LOG('_XML_GetValue @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
		Return -1
	EndIf
	If IsArray($iXMLValue) Then
		Return $iXMLValue
	Else
		_LOG('_XML_GetValue (' & $iXpath & ') is not an Array', 2, $iLOGPath)
		Return -1
	EndIf

	Return -1
EndFunc   ;==>_XML_ListValue

; #FUNCTION# ===================================================================================================
; Name...........: _XML_ListNode
; Description ...: List Nodes in XML File or XML Object
; Syntax.........: _XML_ListNode($iXpath, [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the Node to read
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - Array with all the data ([0][0] = Nb of Values ; [x][0] = Node Name ; [x][1] = Node Value)
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......: No attribute
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_ListNode($iXpath, $iXMLPath = "", $oXMLDoc = "")
	Local $iXMLValue = -1
	If $iXMLPath = "" And $oXMLDoc = "" Then Return -1
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then Return -1
	EndIf

	$iXMLValue = _XML_GetChildren($oXMLDoc, $iXpath)
	If @error Then
		_LOG('_XML_GetChildNodes ERROR (' & $iXpath & ')', 2, $iLOGPath)
		_LOG('_XML_GetChildNodes @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
		Return -1
	EndIf
	If IsArray($iXMLValue) Then
		Return $iXMLValue
	Else
		_LOG('_XML_GetValue (' & $iXpath & ') is not an Array', 2, $iLOGPath)
		Return -1
	EndIf
	Return -1
EndFunc   ;==>_XML_ListNode

; #FUNCTION# ===================================================================================================
; Name...........: _XML_Make
; Description ...: Create an XML File and Object
; Syntax.........: _XML_Make($iXMLPath,$iRoot,[$iUTF8 = True])
; Parameters ....: $iXMLPath	- Path to the XML File
;                  $iRoot		- Xpath Root
;                  $iUTF8		- UTF8 encoding
; Return values .: Success      - Object contening the XML File
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_Make($iXMLPath, $iRoot, $iUTF8 = True)
	FileDelete($iXMLPath)
	Local $oXMLDoc = _XML_CreateFile($iXMLPath, $iRoot, $iUTF8)
	If @error Then
		_LOG('_XML_CreateFile @error:' & @CRLF & XML_My_ErrorParser(@error), 2, $iLOGPath)
		Return -1
	EndIf
	Return $oXMLDoc
EndFunc   ;==>_XML_Make

; #FUNCTION# ===================================================================================================
; Name...........: _XML_WriteValue
; Description ...: Create a node and is value in XML File or XML Object
; Syntax.........: _XML_WriteValue($iXpath, [$iValue=""], [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the value to read
;                  $iValue		- Value to write
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - 1
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_WriteValue($iXpath, $iValue = "", $iXMLPath = "", $oXMLDoc = "", $ipos = "last()")
	Local $iXMLValue = -1, $oNode, $iXpathSplit, $iXMLAttributeName
	If $iXMLPath = "" And $oXMLDoc = "" Then Return -1
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then Return -1
	EndIf

	$iXpathSplit = StringSplit($iXpath, "/")
	$iXMLChildName = $iXpathSplit[UBound($iXpathSplit) - 1]
	$iXpath = StringTrimRight($iXpath, StringLen($iXMLChildName) + 1)
	_XML_CreateChildWAttr($oXMLDoc, $iXpath & "[" & $ipos & "]", $iXMLChildName, Default, $iValue)
	If @error Then
		_LOG('_XML_CreateChildWAttr ERROR (' & $iXpath & ')', 2, $iLOGPath)
		_LOG('_XML_CreateChildWAttr @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
		Return -1
	EndIf
	Return 1
EndFunc   ;==>_XML_WriteValue

; #FUNCTION# ===================================================================================================
; Name...........: _XML_WriteAttributs
; Description ...: Read Data in XML File or XML Object
; Syntax.........: _XML_WriteAttributs($iXpath, $iAttribute, [$iValue=""], [$iXMLPath=""], [$oXMLDoc=""])
; Parameters ....: $iXpath		- Xpath to the value to read
;                  $iAttribute	- Attribute name
;                  $iValue		- Value to write
;                  $iXMLPath	- Path to the XML File
;                  $oXMLDoc		- Object contening the XML File
; Return values .: Success      - 1
;                  Failure      - -1
; Author ........: Screech
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; No
Func _XML_WriteAttributs($iXpath, $iAttribute, $iValue = "", $iXMLPath = "", $oXMLDoc = "", $ipos = "last()")
	Local $iXMLValue = -1, $oNode, $iXpathSplit, $iXMLAttributeName
	If $iXMLPath = "" And $oXMLDoc = "" Then Return -1
	If $iXMLPath <> "" Then
		$oXMLDoc = _XML_Open($iXMLPath)
		If $oXMLDoc = -1 Then Return -1
	EndIf

	_XML_SetAttrib($oXMLDoc, $iXpath & "[" & $ipos & "]", $iAttribute, $iValue)
	If @error Then
		_LOG('_XML_SetAttrib ERROR (' & $iXpath & ')', 2, $iLOGPath)
		_LOG('_XML_SetAttrib @error:' & @CRLF & XML_My_ErrorParser(@error), 3, $iLOGPath)
		Return -1
	EndIf
	Return 1
EndFunc   ;==>_XML_WriteAttributs

#EndRegion XML Function

#Region XML DOM Error/Event Handling
; This COM Error Hanlder will be used globally (excepting inside UDF Functions)
Global $oErrorHandler = ObjEvent("AutoIt.Error", ErrFunc_CustomUserHandler_MAIN)
#forceref $oErrorHandler

; This is SetUp for the transfer UDF internal COM Error Handler to the user function
_XML_ComErrorHandler_UserFunction(ErrFunc_CustomUserHandler_XML)

Func ErrFunc_CustomUserHandler_MAIN($oError)
	ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : MainScript ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>ErrFunc_CustomUserHandler_MAIN

Func ErrFunc_CustomUserHandler_XML($oError)
	; here is declared another path to UDF au3 file
	; thanks to this with using _XML_ComErrorHandler_UserFunction(ErrFunc_CustomUserHandler_XML)
	;  you get errors which after pressing F4 in SciTE4AutoIt you goes directly to the specified UDF Error Line
	ConsoleWrite('XMLWrapperEx' & " (" & $oError.scriptline & ") : UDF ==> COM Error intercepted ! " & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>ErrFunc_CustomUserHandler_XML

Func XML_DOM_EVENT_ondataavailable()
	#CS
		ondataavailable Event
		https://msdn.microsoft.com/en-us/library/ms754530(v=vs.85).aspx
	#CE
	Local $oEventObj = @COM_EventObj
	ConsoleWrite('@COM_EventObj = ' & ObjName($oEventObj, 3) & @CRLF)

	Local $sMessage = 'XML_DOM_EVENT_ fired "ondataavailable"' & @CRLF
	ConsoleWrite($sMessage)
EndFunc   ;==>XML_DOM_EVENT_ondataavailable

Func XML_DOM_EVENT_onreadystatechange()
	#CS
		onreadystatechange Event
		https://msdn.microsoft.com/en-us/library/ms759186(v=vs.85).aspx
	#CE
	Local $oEventObj = @COM_EventObj
	ConsoleWrite('@COM_EventObj = ' & ObjName($oEventObj, 3) & @CRLF)

	Local $sMessage = 'XML_DOM_EVENT_ fired "onreadystatechange" : ReadyState = ' & $oEventObj.ReadyState & @CRLF
	ConsoleWrite($sMessage)

EndFunc   ;==>XML_DOM_EVENT_onreadystatechange

Func XML_DOM_EVENT_ontransformnode($oNodeCode_XSL, $oNodeData_XML, $bBool)
	#forceref $oNodeCode_XSL, $oNodeData_XML, $bBool
	#CS
		ontransformnode Event
		https://msdn.microsoft.com/en-us/library/ms767521(v=vs.85).aspx
	#CE
	Local $oEventObj = @COM_EventObj
	ConsoleWrite('@COM_EventObj = ' & ObjName($oEventObj, 3) & @CRLF)

	Local $sMessage = 'XML_DOM_EVENT_ fired "ontransformnode"' & @CRLF
	ConsoleWrite($sMessage)

EndFunc   ;==>XML_DOM_EVENT_ontransformnode

; #FUNCTION# ====================================================================================================================
; Name ..........: XML_My_ErrorParser
; Description ...: Changing $XML_ERR_ ... to human readable description
; Syntax ........: XML_My_ErrorParser($iXMLWrapper_Error, $iXMLWrapper_Extended)
; Parameters ....: $iXMLWrapper_Error	- an integer value.
;                  $iXMLWrapper_Extended           - an integer value.
; Return values .: description as string
; Author ........: mLipok
; Modified ......:
; Remarks .......: This function is only example of how user can parse @error and @extended to human readable description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func XML_My_ErrorParser($iXMLWrapper_Error, $iXMLWrapper_Extended = 0)
	Local $sErrorInfo = ''
	Switch $iXMLWrapper_Error
		Case $XML_ERR_SUCCESS
			$sErrorInfo = '$XML_ERR_SUCCESS=' & $XML_ERR_SUCCESS & @CRLF & 'All is ok.'
		Case $XML_ERR_GENERAL
			$sErrorInfo = '$XML_ERR_GENERAL=' & $XML_ERR_GENERAL & @CRLF & 'The error which is not specifically defined.'
		Case $XML_ERR_COMERROR
			$sErrorInfo = '$XML_ERR_COMERROR=' & $XML_ERR_COMERROR & @CRLF & 'COM ERROR OCCURED. Check @extended and your own error handler function for details.'
		Case $XML_ERR_ISNOTOBJECT
			$sErrorInfo = '$XML_ERR_ISNOTOBJECT=' & $XML_ERR_ISNOTOBJECT & @CRLF & 'No object passed to function'
		Case $XML_ERR_INVALIDDOMDOC
			$sErrorInfo = '$XML_ERR_INVALIDDOMDOC=' & $XML_ERR_INVALIDDOMDOC & @CRLF & 'Invalid object passed to function'
		Case $XML_ERR_INVALIDATTRIB
			$sErrorInfo = '$XML_ERR_INVALIDATTRIB=' & $XML_ERR_INVALIDATTRIB & @CRLF & 'Invalid object passed to function.'
		Case $XML_ERR_INVALIDNODETYPE
			$sErrorInfo = '$XML_ERR_INVALIDNODETYPE=' & $XML_ERR_INVALIDNODETYPE & @CRLF & 'Invalid object passed to function.'
		Case $XML_ERR_OBJCREATE
			$sErrorInfo = '$XML_ERR_OBJCREATE=' & $XML_ERR_OBJCREATE & @CRLF & 'Object can not be created.'
		Case $XML_ERR_NODECREATE
			$sErrorInfo = '$XML_ERR_NODECREATE=' & $XML_ERR_NODECREATE & @CRLF & 'Can not create Node - check also COM Error Handler'
		Case $XML_ERR_NODEAPPEND
			$sErrorInfo = '$XML_ERR_NODEAPPEND=' & $XML_ERR_NODEAPPEND & @CRLF & 'Can not append Node - check also COM Error Handler'
		Case $XML_ERR_PARSE
			$sErrorInfo = '$XML_ERR_PARSE=' & $XML_ERR_PARSE & @CRLF & 'Error: with Parsing objects, .parseError.errorCode=' & $iXMLWrapper_Extended & ' Use _XML_ErrorParser_GetDescription() for get details.'
		Case $XML_ERR_PARSE_XSL
			$sErrorInfo = '$XML_ERR_PARSE_XSL=' & $XML_ERR_PARSE_XSL & @CRLF & 'Error with Parsing XSL objects .parseError.errorCode=' & $iXMLWrapper_Extended & ' Use _XML_ErrorParser_GetDescription() for get details.'
		Case $XML_ERR_LOAD
			$sErrorInfo = '$XML_ERR_LOAD=' & $XML_ERR_LOAD & @CRLF & 'Error opening specified file.'
		Case $XML_ERR_SAVE
			$sErrorInfo = '$XML_ERR_SAVE=' & $XML_ERR_SAVE & @CRLF & 'Error saving file.'
		Case $XML_ERR_PARAMETER
			$sErrorInfo = '$XML_ERR_PARAMETER=' & $XML_ERR_PARAMETER & @CRLF & 'Wrong parameter passed to function.'
		Case $XML_ERR_ARRAY
			$sErrorInfo = '$XML_ERR_ARRAY=' & $XML_ERR_ARRAY & @CRLF & 'Wrong array parameter passed to function. Check array dimension and conent.'
		Case $XML_ERR_XPATH
			$sErrorInfo = '$XML_ERR_XPATH=' & $XML_ERR_XPATH & @CRLF & 'XPath syntax error - check also COM Error Handler.'
		Case $XML_ERR_NONODESMATCH
			$sErrorInfo = '$XML_ERR_NONODESMATCH=' & $XML_ERR_NONODESMATCH & @CRLF & 'No nodes match the XPath expression'
		Case $XML_ERR_NOCHILDMATCH
			$sErrorInfo = '$XML_ERR_NOCHILDMATCH=' & $XML_ERR_NOCHILDMATCH & @CRLF & 'There is no Child in nodes matched by XPath expression.'
		Case $XML_ERR_NOATTRMATCH
			$sErrorInfo = '$XML_ERR_NOATTRMATCH=' & $XML_ERR_NOATTRMATCH & @CRLF & 'There is no such attribute in selected node.'
		Case $XML_ERR_DOMVERSION
			$sErrorInfo = '$XML_ERR_DOMVERSION=' & $XML_ERR_DOMVERSION & @CRLF & 'DOM Version: ' & 'MSXML Version ' & $iXMLWrapper_Extended & ' or greater required for this function'
		Case $XML_ERR_EMPTYCOLLECTION
			$sErrorInfo = '$XML_ERR_EMPTYCOLLECTION=' & $XML_ERR_EMPTYCOLLECTION & @CRLF & 'Collections of objects was empty'
		Case $XML_ERR_EMPTYOBJECT
			$sErrorInfo = '$XML_ERR_EMPTYOBJECT=' & $XML_ERR_EMPTYOBJECT & @CRLF & 'Object is empty'
		Case Else
			$sErrorInfo = '=' & $iXMLWrapper_Error & @CRLF & 'NO ERROR DESCRIPTION FOR THIS @error'
	EndSwitch

	Local $sExtendedInfo = ''
	Switch $iXMLWrapper_Error
		Case $XML_ERR_COMERROR, $XML_ERR_NODEAPPEND, $XML_ERR_NODECREATE
			$sExtendedInfo = 'COM ERROR NUMBER (@error returned via @extended) =' & $iXMLWrapper_Extended
		Case $XML_ERR_PARAMETER
			$sExtendedInfo = 'This @error was fired by parameter: #' & $iXMLWrapper_Extended
		Case Else
			Switch $iXMLWrapper_Extended
				Case $XML_EXT_DEFAULT
					$sExtendedInfo = '$XML_EXT_DEFAULT=' & $XML_EXT_DEFAULT & @CRLF & 'Default - Do not return any additional information'
				Case $XML_EXT_XMLDOM
					$sExtendedInfo = '$XML_EXT_XMLDOM=' & $XML_EXT_XMLDOM & @CRLF & '"Microsoft.XMLDOM" related Error'
				Case $XML_EXT_DOMDOCUMENT
					$sExtendedInfo = '$XML_EXT_DOMDOCUMENT=' & $XML_EXT_DOMDOCUMENT & @CRLF & '"Msxml2.DOMDocument" related Error'
				Case $XML_EXT_XSLTEMPLATE
					$sExtendedInfo = '$XML_EXT_XSLTEMPLATE=' & $XML_EXT_XSLTEMPLATE & @CRLF & '"Msxml2.XSLTemplate" related Error'
				Case $XML_EXT_SAXXMLREADER
					$sExtendedInfo = '$XML_EXT_SAXXMLREADER=' & $XML_EXT_SAXXMLREADER & @CRLF & '"MSXML2.SAXXMLReader" related Error'
				Case $XML_EXT_MXXMLWRITER
					$sExtendedInfo = '$XML_EXT_MXXMLWRITER=' & $XML_EXT_MXXMLWRITER & @CRLF & '"MSXML2.MXXMLWriter" related Error'
				Case $XML_EXT_FREETHREADEDDOMDOCUMENT
					$sExtendedInfo = '$XML_EXT_FREETHREADEDDOMDOCUMENT=' & $XML_EXT_FREETHREADEDDOMDOCUMENT & @CRLF & '"Msxml2.FreeThreadedDOMDocument" related Error'
				Case $XML_EXT_XMLSCHEMACACHE
					$sExtendedInfo = '$XML_EXT_XMLSCHEMACACHE=' & $XML_EXT_XMLSCHEMACACHE & @CRLF & '"Msxml2.XMLSchemaCache." related Error'
				Case $XML_EXT_STREAM
					$sExtendedInfo = '$XML_EXT_STREAM=' & $XML_EXT_STREAM & @CRLF & '"ADODB.STREAM" related Error'
				Case $XML_EXT_ENCODING
					$sExtendedInfo = '$XML_EXT_ENCODING=' & $XML_EXT_ENCODING & @CRLF & 'Encoding related Error'
				Case Else
					$sExtendedInfo = '$iXMLWrapper_Extended=' & $iXMLWrapper_Extended & @CRLF & 'NO ERROR DESCRIPTION FOR THIS @extened'
			EndSwitch
	EndSwitch
	; return back @error and @extended for further debuging
	Return SetError($iXMLWrapper_Error, $iXMLWrapper_Extended, _
			'@error description:' & @CRLF & _
			$sErrorInfo & @CRLF & _
			@CRLF & _
			'@extended description:' & @CRLF & _
			$sExtendedInfo & @CRLF & _
			'')

EndFunc   ;==>XML_My_ErrorParser
#EndRegion XML DOM Error/Event Handling

#Region SendMail Function

Func _CreateMailslot($sMailSlotName)
	Local $hHandle = _MailSlotCreate($sMailSlotName)
	If @error Then
		_LOG("MailSlot error : Failed to create new account! (" & $sMailSlotName & ")", 2, $iLOGPath)
		Return -1
	EndIf
	Return $hHandle
EndFunc   ;==>_CreateMailslot


Func _SendMail($hHandle, $sDataToSend)
	If $sDataToSend Then
		_MailSlotWrite($hHandle, $sDataToSend, 2)
		Switch @error
			Case 1
				_LOG("MailSlot error : Account that you try to send to doesn't exist!", 2, $iLOGPath)
				Return -1
			Case 2
				_LOG("MailSlot error : Message is blocked!", 2, $iLOGPath)
				Return -1
			Case 3
				_LOG("MailSlot error : Message is send but there is an open handle left.", 2, $iLOGPath)
				Return -1
			Case 4
				_LOG("MailSlot error : All is fucked up!", 2, $iLOGPath)
				Return -1
			Case Else
				_LOG("MailSlot : Sucessfully sent =" & $sDataToSend, 3, $iLOGPath)
				Return 1
		EndSwitch
	Else
		_LOG("MailSlot error : Nothing to send.", 2, $iLOGPath)
	EndIf
EndFunc   ;==>_SendMail

Func _ReadMessage($hHandle)
	Local $iSize = _MailSlotCheckForNextMessage($hHandle)
	If $iSize Then
		Return _MailSlotRead($hHandle, $iSize, 2)
	Else
		_LOG("MailSlot error : MailSlot is empty", 2, $iLOGPath)
		Return -1
	EndIf
EndFunc   ;==>_ReadMessage


Func _CheckCount($hHandle)
	Local $iCount = _MailSlotGetMessageCount($hHandle)
	Switch $iCount
		Case 0
			_LOG("MailSlot : No new messages", 3, $iLOGPath)
		Case 1
			_LOG("MailSlot : There is 1 message waiting to be read.", 3, $iLOGPath)
		Case Else
			_LOG("MailSlot : There are " & $iCount & " messages waiting to be read.", 3, $iLOGPath)
	EndSwitch
	Return $iCount
EndFunc   ;==>_CheckCount

Func _CheckAnswer($hHandle, $idata)
	Local $iAnwser = ""
	Local $iSize
	Local $iCounter = 0
	While $iAnwser <> $idata And $iCounter < 500
		$iSize = _MailSlotCheckForNextMessage($hHandle)
		If $iSize Then $idata = _MailSlotRead($hHandle, $iSize, 2)
		$iCounter += 1
	WEnd
	Return 1
EndFunc   ;==>_CheckAnswer


Func _CloseMailAccount(ByRef $hHandle)
	If _MailSlotClose($hHandle) Then
		$hHandle = 0
		_LOG("MailSlot : Account succesfully closed.", 3, $iLOGPath)
		Return 1
	Else
		_LOG("MailSlot error : Account could not be closed!", 2, $iLOGPath)
		Return -1
	EndIf

EndFunc   ;==>_CloseMailAccount


Func _RestoreAccount($hHandle)
	Local $hMailSlotHandle = _MailSlotCreate($hHandle)
	If @error Then
		_LOG("MailSlot error : Account could not be created!", 2, $iLOGPath)
		Return -1
	Else
		_LOG("MailSlot error : New account with the same address successfully created!", 2, $iLOGPath)
		Return $hMailSlotHandle
	EndIf
EndFunc   ;==>_RestoreAccount

#EndRegion SendMail Function
