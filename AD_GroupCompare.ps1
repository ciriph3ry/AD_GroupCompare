# Import the required module
Import-Module ActiveDirectory

		# Prompt the user to enter the first username
		$firstUser = Read-Host "Enter the first username"

		# Prompt the user to enter the second username
		$secondUser = Read-Host "Enter the second username"

		# Retrieve group membership for the first user
		$firstUserGroups = Get-ADUser $firstUser -Properties MemberOf |
                   Select-Object -ExpandProperty MemberOf |
                   ForEach-Object { (Get-ADGroup $_).Name }

		# Retrieve group membership for the second user
		$secondUserGroups = Get-ADUser $secondUser -Properties MemberOf |
                    Select-Object -ExpandProperty MemberOf |
                    ForEach-Object { (Get-ADGroup $_).Name }

		# Prepare data for side-by-side comparison
		$allGroups = $firstUserGroups + $secondUserGroups | Select-Object -Unique
		$comparisonData = foreach ($group in $allGroups) {
			$firstUserInGroup = $firstUserGroups -contains $group
			$secondUserInGroup = $secondUserGroups -contains $group

			[PSCustomObject]@{
				Group = $group
				FirstUser = $firstUserInGroup
				SecondUser = $secondUserInGroup
			}
		}

		# Calculate the maximum width of the group names
		$maxGroupNameWidth = $comparisonData.Group | Measure-Object -Maximum Length | Select-Object -ExpandProperty Maximum
		
		# Display the comparison side by side with colors
		Write-Host "Group Membership Comparison"
		Write-Host "---------------------------"
		Write-Host ("{0,-$maxGroupNameWidth} {1,-12} {2}" -f "", $firstUser, $secondUser)
		Write-Host ("{0,-$maxGroupNameWidth} {1,-12} {2}" -f "", ("-" * $firstUser.Length), ("-" * $secondUser.Length))

		foreach ($groupData in $comparisonData) {
			$group = $groupData.Group
			$firstUserInGroup = $groupData.FirstUser
			$secondUserInGroup = $groupData.SecondUser

			# Set the color based on group membership
			$firstUserColor = if ($firstUserInGroup) { "Green" } else { "Red" }
			$secondUserColor = if ($secondUserInGroup) { "Green" } else { "Red" }

			# Write the group membership with color
			Write-Host ("{0,-$maxGroupNameWidth} {1,-12} {2}" -f $group, $firstUserInGroup, $secondUserInGroup) -ForegroundColor $firstUserColor, $secondUserColor
		}
			}
