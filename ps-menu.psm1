function DrawMenu{
    param ($menuItems, $menuPosition, $Multiselect, $selection, $columnCount=$false)
	if($columnCount){
		$maxWidth = ($menuItems | Measure-Object -Property Length -Maximum).Maximum
		for($i = 0; $i -le $menuItems.length;$i++){
			$object = $menuItems[$i]
			if($object){
				$text = "$object$(" " * ($maxWidth - $object.Length))"
				if($Multiselect){
					if($selection -contains $i){
					$item = "[x] $text"
					}else{
						$item = "[ ] $text"
					}
				}else{
					$item = "  $text  "
				}
				if($i -eq $menuPosition){
					Write-Host ">$item<" -ForegroundColor Green -NoNewline
				}else{
					Write-Host " $item " -NoNewline
				}
			}
			if(-not (($i +1) % $columnCount)){
				Write-Host ''
			}
		}
	}else{
		for($i = 0; $i -le $menuItems.length;$i++){
			$item = $menuItems[$i]
			if($item){
				if($Multiselect)
				{
					if($selection -contains $i){
						$item = '[x] ' + $item
					}
					else{
						$item = '[ ] ' + $item
					}
				}
				if($i -eq $menuPosition){
					Write-Host "> $($item)" -ForegroundColor Green
				}else{
					Write-Host "  $($item)"
				}
			}
		}
	}
}

function Switch-Selection{
	param($pos,[array]$selection)
	if($selection -contains $pos){ 
		$result = $selection | Where-Object{$_ -ne $pos}
	}
	else{
		$selection += $pos
		$result = $selection
	}
	$result
}

function Menu{
    param([array]$menuItems,[switch]$ReturnIndex=$false,[switch]$Multiselect,[switch]$Table=$false)
    $keycode = 0
    $pos = 0
    $selection = @()
    if($menuItems.Length -gt 0){
		try{
			$keys = [PSCustomObject]@{ # Keycode list: https://learn.microsoft.com/en-us/dotnet/api/system.consolekey?view=net-9.0
				up = 38,75		# Up arrow, k
				down = 40,74	# Down arrow, j
				left = 37,72	# Left arrow, h
				right = 39,76	# Right arrow, l
				home = 36		# Home key
				end = 35		# End key
				toggle = 32		# Space
			}
			if($Table){
				try{
					$columnCount = [Math]::Floor([System.Console]::WindowWidth / (($menuItems | Measure-Object -Property Length -Maximum -ErrorAction Stop).Maximum +6))
					$lineCount = [Math]::Ceiling($menuItems.Count / $columnCount)
				}catch{ # If the array objects cannot be measured.
					$columnCount = 0
					$lineCount = 0
				}
			}
			$startPos = [System.Console]::CursorTop
			[System.Console]::CursorVisible = $false #prevents cursor flickering
			DrawMenu $menuItems $pos $Multiselect $selection $columnCount
			While($keycode -ne 13 -and $keycode -ne 27){
				$keycode = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
				switch($keycode){
					{$keys.up -contains $_ -and $lineCount -gt 1}{$pos = $pos - $columnCount}
					{$keys.down -contains $_ -and $lineCount -gt 1}{$pos = $pos + $columnCount}
					{$keys.up -contains $_ -and -not $columnCount}{$pos--}
					{$keys.down -contains $_ -and -not $columnCount}{$pos++}
					{$keys.left -contains $_}{$pos--}
					{$keys.right -contains $_}{$pos++}
					{$keys.home -contains $_}{$pos = 0}
					{$keys.end -contains $_}{$pos = $menuItems.length - 1}
					{$keys.toggle -contains $_}{$selection = Switch-Selection $pos $selection}
				}
				switch($pos){ # When attempting to move the cursor outside of the array
					{$_ -lt 0}{$pos = 0}
					{$_ -ge $menuItems.length}{$pos = $menuItems.length -1}
				}
				if($keycode -eq 27){ # Esc key
					$pos = $null
				}else{
					if($columnCount){
						$startPos = [System.Console]::CursorTop - $lineCount
					}else{
						$startPos = [System.Console]::CursorTop - $menuItems.Length
					}
					[System.Console]::SetCursorPosition(0, $startPos)
					DrawMenu $menuItems $pos $Multiselect $selection $columnCount
				}
			}
		}finally{
			if($columnCount){
				[System.Console]::SetCursorPosition(0, $startPos + $lineCount)
			}else{
				[System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
			}
			[System.Console]::CursorVisible = $true
		}
	}else{
		$pos = $null
	}

	if($pos){
		if(-not $Multiselect){
			$selection = $pos
		}
		if($ReturnIndex){
			return $selection
		}else{
			return $menuItems[$selection]
		}
	}

		
	<#
	.SYNOPSIS
		Displays the menu items, returning the chosen items to the user.

	.DESCRIPTION
		Displays the given menu items, allowing the user to choose the
		outputted item(s) by navigating the menu using the arrow keys and
		validating their selection with the "Enter" key.
		The "Esc" key will close the menu, returning nothing.

	.PARAMETER menuItems
		Array containing the items that are to be shown.

	.PARAMETER Multiselect
		Will allow multiple items to be selected from the displayed menu.
		Adding an items to the selection is done using the space-bar.

	.PARAMETER ReturnIndex
		Will return the index of the selected item(s) instead of the item
		itself.
	
	.PARAMETER Table
		Will display the given items in columns, if the space of the current
		host window allows for it.

	.EXAMPLE
		menu @("option 1", "option 2", "option 3")

	.EXAMPLE
		menu (gci) -MultiSelect

	.EXAMPLE
		menu (Get-LocalUser).Name -MultiSelect -Table -ReturnIndex

	.INPUTS
		None. You cannot pipe data into "menu".

	.OUTPUTS
		The selected menu item(s) or their index.

	.LINK
		[System.Console]::SetCursorPosition

	.LINK
		[System.Console]::CursorTop
	#>
}

