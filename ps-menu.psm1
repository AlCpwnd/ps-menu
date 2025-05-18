function DrawMenu{
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    for($i = 0; $i -le $menuItems.length;$i++){
		if($null -ne $menuItems[$i]){
			$item = $menuItems[$i]
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
    param([array]$menuItems,[switch]$ReturnIndex=$false,[switch]$Multiselect)
    $keycode = 0
    $pos = 0
    $selection = @()
    if($menuItems.Length -gt 0){
		try{
			$keys = [PSCustomObject]@{ # Keycode list: https://learn.microsoft.com/en-us/dotnet/api/system.consolekey?view=net-9.0
				up = 38,75		# Up arrow, k
				down = 40,74	# Down arrow, j
				home = 36		# Home key
				end = 35		# End key
				toggle = 32		# Space
			}
			$startPos = [System.Console]::CursorTop		
			[System.Console]::CursorVisible = $false #prevents cursor flickering
			DrawMenu $menuItems $pos $Multiselect $selection
			While($keycode -ne 13 -and $keycode -ne 27){
				$keycode = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
				switch($keycode){
					{$keys.up -contains $_}{$pos--}
					{$keys.down -contains $_}{$pos++}
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
					$startPos = [System.Console]::CursorTop - $menuItems.Length
					[System.Console]::SetCursorPosition(0, $startPos)
					DrawMenu $menuItems $pos $Multiselect $selection
				}
			}
		}finally{
			[System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
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
}

