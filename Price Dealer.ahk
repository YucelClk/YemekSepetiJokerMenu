SendMode Input
;SetBatchLines -1
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
CoordMode, Mouse, Client
SetWorkingDir %A_ScriptDir%
;#NoTrayIcon

; import from file
; priceArray := [13, 18, 21, 6, 5, 3] ; price list of restaurant
; priceFloor := 22 ; min orderable price of restaurant
; difference := 2 ; max price willing to pay above floor
; aimedFloor := 30 ; 30->20, 40->25, 70->45 ;; aimed joker
#include priceList.var

; private vars
if (aimedFloor == 30)
	newAimedFloor := 20
else if (aimedFloor == 40)
	newAimedFloor := 25
else if (aimedFloor == 70)
	newAimedFloor := 45
else
	msgbox, Wrong aimedFloor


if (priceFloor >= aimedFloor)
	floor := priceFloor
else
	floor := aimedFloor + (priceFloor - newAimedFloor)
; msgbox, % "target: " floor

Msgbox, 4,, % "The Floor is: " floor "`nWould you like to calculate?"
IfMsgBox No
	ExitApp


shoppingCart := []
resultString = 
fun(shoppingCart, 0, 0, 1, resultString)

; write output to file
fileName = menus.var
file := FileOpen(fileName, "w")

if !isObject(file)
	Msgbox, Can't write to output
else
{
	file.Write(resultString)
}
file.Close()

; Return
ExitApp


fun(shoppingCart, currentPrice, addition, priceArrayIndex, ByRef resultString)
{
	; neccessary vars
	global floor
	global priceArray
	global difference

	; create local shopping array
	; we store possibly bought items in it
	;; we create a new one because every brancing have a
	;; different possibly of item additions
	localCart := []
	loop, % shoppingCart.Length()
	{
		localCart.push(shoppingCart[A_Index])
	}
	
	; buy current item
	currentPrice += addition
	localCart.push(addition)
	; if our prive is above floor end branch and show result
	; msgbox, % "currentPrice: " currentPrice ", floor: " floor ", difference: " difference
	if ( (currentPrice >= floor) && (currentPrice <= (floor + difference) ) )
	{
		resultString = % resultString "=================`nTotal: " currentPrice "TL `n"
		; show every item in the local cart
		loop, % (localCart.Length() - 2)
		{
			resultString = % resultString localCart[A_Index + 1]  ", "
		}
		resultString = % resultString localCart[localCart.MaxIndex()] "`n"
		; msgbox, % "priceArrayIndex: " priceArrayIndex
		; msgbox, % resultString
		
		Return
	}
	else if (currentPrice > floor + difference)
	{
		; somehow need to prevent just one infinity branch
		Return
	}
	else
	{
		; in else we try other items that are in priceArray
		loop, % priceArray.Length()
		{
			; prevent duplicate entries
			;;	duplicate entries drown the results
			if (A_Index < priceArrayIndex)
			{
				; msgbox, % "A_Index: " A_Index ", priceArrayIndex: " priceArrayIndex
				Continue
			}
		
			; recursively try each item
			; continue putting items on top of local cart and currentPrice
			; But add specific A_Index item in that node			
			fun(localCart, currentPrice, priceArray[A_Index], A_Index, resultString)
		}
	}
	
	Return
}


f11::
	Run, %A_ScriptDir%\%A_ScriptName%
Return

*~f12::
	Suspend, Off
ExitApp
