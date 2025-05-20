function DrawMenu{
    param ($menuItems, $menuPosition, $Multiselect, $selection, $columnCount=$false)
	$highLight = @{
		ForegroundColor = [System.Console]::BackgroundColor
		BackgroundColor = [System.Console]::ForegroundColor
	}
	if($columnCount){
		$width = ($menuItems | Measure-Object -Property Length -Maximum).Maximum
		for($i = 0; $i -le $menuItems.length;$i++){
			$object = $menuItems[$i]
			if($object){
				$text = "$object$(" " * ($width - $object.Length))"
				if($Multiselect -and $selection -contains $i){
					$item = "[x] $text "
				}else{
					$item = "[ ] $text "
				}
				if($i -eq $menuPosition){
					Write-Host $item @highLight -NoNewline
				}else{
					Write-Host $item -NoNewline
				}
			}
			if(-not (($i +1) % $columnCount)){
				Write-Host ''
			}
		}
	}else{
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
				$columnCount = [Math]::Floor([System.Console]::WindowWidth / (($menuItems | Measure-Object -Property Length -Maximum).Maximum +4))
				$lineCount = [Math]::Ceiling($menuItems.Count / $columnCount)
			}
			$startPos = [System.Console]::CursorTop
			[System.Console]::CursorVisible = $false #prevents cursor flickering
			DrawMenu $menuItems $pos $Multiselect $selection $columnCount
			While($keycode -ne 13 -and $keycode -ne 27){
				$keycode = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
				if($columnCount){
					switch($keycode){
						{$keys.up -contains $_ -and $lineCount -gt 1}{$pos = $pos - $columnCount}
						{$keys.down -contains $_ -and $lineCount -gt 1}{$pos = $pos + $columnCount}
						{$keys.left -contains $_}{$pos--}
						{$keys.right -contains $_}{$pos++}
						{$keys.home -contains $_}{$pos = 0}
						{$keys.end -contains $_}{$pos = $menuItems.length - 1}
						{$keys.toggle -contains $_}{$selection = Switch-Selection $pos $selection}
					}
				}else{
					switch($keycode){
						{$keys.up -contains $_}{$pos--}
						{$keys.down -contains $_}{$pos++}
						{$keys.home -contains $_}{$pos = 0}
						{$keys.end -contains $_}{$pos = $menuItems.length - 1}
						{$keys.toggle -contains $_}{$selection = Switch-Selection $pos $selection}
					}
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
}

