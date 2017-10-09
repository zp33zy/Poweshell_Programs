<#
	Creator: Zachary C. Preston
	Date   : 7/10/2017
	Company: LRC
#>

function isLegislator([string]$user)
{
	$fullName = Get-ADUser -Identity $user | select -expand Name
	if ($fullName.Contains("(State"))
	{
		Write-Host "true"
		return $true
	}
	else
	{
		return $false
	}
}
function generateNewPassword([string]$user)
{
	
	$userToReset = $user
	
	$newPass = $userToReset[$userToReset.IndexOf('_') + 1]
	$newPass = $newPass + $userToReset[0]
	$newPass = $newPass.ToLower()
	$dayOfWeek = (Get-Date).DayOfWeek.value__
	switch ($dayOfWeek)
	{
		1
		{
			$newPass += "!";
			break
		}
		2
		{
			$newPass += "@";
			break
		}
		3
		{
			$newPass += "#";
			break
		}
		4
		{
			$newPass += "`$";
			break
		}
		5
		{
			$newPass += "%";
			break
		}
		default
		{
			$newPass += "!";
			break
		}
	}
	if (isLegislator -user $user)
	{
		$UserOU = "legi"
	}
	else
	{
		[string]$distinguishedName = Get-ADUser -Identity $user | select -expand DistinguishedName
		[string[]]$OUs = $distinguishedName.Split("=")
		$UserOU = $OUs[3].Substring(0, $OUs[3].IndexOf(","))
		if ($UserOU.Length -le 3)
		{
			$UserOU = $UserOU.Substring(0, 3) + "1"
		}
		else
		{
			$UserOU = $UserOU.Substring(0, 4)
		}
		if ($UserOU.Equals("STAT") -or $UserOU.Equals("Stat"))
		{
			$UserOU = "sgov"
		}
		$UserOU = $UserOU.ToLower()
	}
	$newPass += $UserOU
	#$minute = 3
	$minute = (Get-Date).Minute
	if ($minute -le 9)
	{
		$newPass += "0" + $minute
	}
	else
	{
		$newPass += $minute
	}
	return $newPass
}
function resetADPassword ([string]$username)
{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	Add-Type -AssemblyName PresentationFramework
	
	[string]$newPassword = generateNewPassword -user $username
	$securePass = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
	$displayName = Get-ADUser $username | select -expand Name
	#$confirmYesNo = [System.Windows.MessageBox]::Show("Reset Password To $newPassword" + "?", "Password Reset For $displayName", 'YesNo', 'Error')
	$confirmBox = New-Object -ComObject Wscript.Shell
	$answer = $confirmBox.popup("Reset " + $username + "'s password to: " + $newPassword + "?", 0, "Reset User Password: " + $username, 4)
	if ($answer -eq 6)
	{
		$secondAnswer = $confirmBox.popup("Commit Changes to $($displayName)?", 0, $displayName + "'s new password: " + $newPassword, 4)
		if ($secondAnswer -eq 6)
		{
			try
			{
				Set-ADAccountPassword $username -NewPassword $securePass -Reset
				unlockAccount -username $username
				$clipboardBiulder = "The Password For The Account: "
				$clipboardBiulder += "$displayName has been reset to: `r`n`t"
				$clipboardBiulder += "$newPassword `r`nThis can be changed after two days.`r`nThank You"
				Set-Clipboard -Value $clipboardBiulder
				$confirmBox.popup("Changes Complete, Results Copied To Clipboard!", 0, "Applied!")
				#$outputBox.AppendText("The password for the account: ")
				return $newPassword
				
			}
			catch
			{
				$confirmBox.popup("Error: Could Not Perform Action!")
			}
		}
		else
		{
			$confirmBox.popup("No Changes Made")
		}
	}
	else
	{
		$confirmBox.popup("No Changes Made")
	}
	
}
function resetADPasswordSpecific ([string]$username, [string]$specificPass)
{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	Add-Type -AssemblyName PresentationFramework
	
	$newPassword = $specificPass
	$securePass = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
	$displayName = Get-ADUser $username | select -expand Name
	$confirmYesNo = [System.Windows.MessageBox]::Show("Reset Password To $newPassword" + "?", "Password Reset For $displayName", 'YesNo', 'Error')
	$confirmBox = New-Object -ComObject Wscript.Shell
	$answer = $confirmBox.popup("Reset " + $username + "'s password to: " + $newPassword + "?", 0, "Reset User Password: " + $username, 4)
	if ($answer -eq 6)
	{
		$secondAnswer = $confirmBox.popup("Commit Changes to $($displayName)?", 0, $displayName + "'s new password: " + $newPassword, 4)
		if ($secondAnswer -eq 6)
		{
			try
			{
				Set-ADAccountPassword $username -NewPassword $securePass -Reset
				unlockAccount -username $username
				$clipboardBiulder = "The Password For The Account: "
				$clipboardBiulder += "$displayName has been reset to: `r`n`t"
				$clipboardBiulder += "$newPassword `r`nThis can be changed after two days.`r`nThank You"
				Set-Clipboard -Value $clipboardBiulder
				$confirmBox.popup("Changes Complete, Results Copied To Clipboard!", 0, "Applied!")
				#$outputBox.AppendText("The password for the account: ")
				
				Write-Host "$displayName $newPassword"
			}
			catch
			{
				$confirmBox.popup("Error: Could Not Perform Action!")
			}
		}
		else
		{
			$confirmBox.popup("No Changes Made")
		}
	}
	else
	{
		$confirmBox.popup("No Changes Made")
	}
	
}
function unlockAccount([string]$username)
{
	Unlock-ADAccount -Identity $username
}
