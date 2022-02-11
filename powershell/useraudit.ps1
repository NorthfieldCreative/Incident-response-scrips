############################################
#### Starting output of data for review ####
#### because it is not presented in the ####
#### RTR console within Crowdstrike     ####
############################################
#$ErrorActionPreference="SilentlyContinue"
#Stop-Transcript | out-null
#$ErrorActionPreference = "Continue"
#Start-Transcript -path C:\Windows\Temp\useraudit.txt -append
###########################################
###########################################
###########################################






### Data Lookup Table according to event ID ###
$AccOperations = DATA { ConvertFrom-StringData -StringData @'
4720 = Account Created
4722 = Account Enabled
4723 = Self Reset Password
4724 = Reset Password
4725 = Account Disabled
4726 = Account Deleted
4731 = Group Created
4732 = Added to Security Group
4733 = Removed from Security Group
4734 = Group Deleted
4781 = Account Renamed
'@}


### Get all the required Security Events ###
Try { 
		$AccOpEvents = Get-WinEvent -FilterHashTable @{LogName="Security";ID=4720,4722,4723,4724,4725,4726,4731,4732,4733,4734,4738,4781}	 -EA Stop	## Get the required events by IDs
		}
catch {
	Try { $LogProperties = Get-WinEvent -ListLog security -EA Stop
			}
	catch {	Write-Host -fore yellow "Cannot Continue. Please run the Powershell in elevated Session."
				exit;
				}		
	write-host  -fore Red "The required Events are not available.`nPlease increase Security Log File Size and try again later."
	Write-Host "Current Log file Size: $($LogProperties.MaximumSizeInBytes/1MB) MB`nLogging Mode: $($LogProperties.LogMode)"
	exit;	
		}

### Check if the Audit Account Management is currently turn on (Audit Success) in local security policy, if not prompt the user to turn it on ###
$NeedtoTurnOnAuditSuccess = 1;
auditpol /get /category:"Account Management" | foreach {$var=$_; @('Computer Account Management','Security Group Management','User Account Management') | foreach { if ($var -match $_ ) { If ($var -match 
'Success' ) { $NeedtoTurnOnAuditSuccess = 0;  } } } }   

### Prompt the user to turn on the Audit Account Management  ###
If ($NeedtoTurnOnAuditSuccess)
	{
	$ConfirmTurnOnAuditSuccess = Read-Host "Audit Account Management is currently turned off. Do you want to turn it on (y/n)?"
	If ($ConfirmTurnOnAuditSuccess -eq 'y' -OR $ConfirmTurnOnAuditSuccess -eq 'yes')
		{
		auditpol /set /category:"Account Management" /success:enable  | out-null
		If ($?)	{ Write-Host -fore green "Audit Account Management Settings in Local Security Policy has been successfully turned on."}
		else { Write-Host -fore Red "Error occurs."}
		}
	}		

###  Filter the events with ID 4738 from other events ####
$objs =@()
$AccOpIsoEvents = $AccOpEvents | ? {    @('4720','4722','4723','4724','4725','4726','4731','4732','4733','4734','4781') -match $_.id     }		## Filter only isolated events (events has separate id for account changes)

$AccID_4738_Events  = $AccOpEvents | ? { $_.id -match 4738 }		## Get events with ID 4738
$AccID_4738_Filtered_Events = $AccID_4738_Events | foreach { if ($AccOpIsoEvents.TimeCreated -match $_.TimeCreated) {} else { $_ }  }		## Skip 4738 events that has same time with other events

### If there are not events of id 4738, then make foreach loop only with the isolated events (NON-4738) ###
If ($AccID_4738_Filtered_Events.count)
	{	
	$AccOpMixedEvents = $AccOpIsoEvents + $AccID_4738_Filtered_Events
	}
else
	{ $AccOpMixedEvents	= $AccOpIsoEvents }
$AccOpMixedEvents | foreach {
			$obj = New-Object -TypeName PsObject -Property @{Audit="";DateTime="";AccountOperation=""; ID="";TargetAccount=""; ExistingAcc=""; InitiatedBy=""; TargetGroup=""; ExistingGrp="";ChangedValue=""  }; 
			$obj.Audit = (($_.KeywordsDisplayNames) | foreach { $_ })[0]
			$obj.DateTime = $_.TimeCreated
			$obj.ID = $_.id
			$obj.AccountOperation = $AccOperations[$_.id.tostring()] 
			$Message = $_.Message
			$SkipEvent = 0 

### Finding the Target Account from SID from $_.Message ###
If ( $_.id -eq 4726 )
	{
		$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+1].split(":")[1].Trim()		## Even the field outputs the  domain\username (in text) in the event viewer,the powershell outputs as SID value differently
		Try {
		$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value		## Check if the SID can be translated into existing account
		$obj.ExistingAcc = "Yes"
		}
		catch {
			Try {
			$obj.TargetAccount = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+2].split(":")[1].Trim()		## If SID can't be translated, then use the 2nd line after the 'Target Account:'
			$obj.ExistingAcc = "No"
			}
			catch {
			$obj.TargetAccount = $SID		## If all above Try statements doesn't work, then ouput the SID as it is.
			$obj.ExistingAcc = "No"
			}
		}
	}

## If the event id is 4720 then it's creating new account ###
elseif ($_.id -eq 4720) {
		$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("New Account:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingAcc = "Yes"
		}
		catch {
			Try {
			$obj.TargetAccount = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("New Account:")+2].split(":")[1].Trim()
			$obj.ExistingAcc = "No"
			}
			catch {
			$obj.TargetAccount = $SID
			$obj.ExistingAcc = "No"
			}
		}
	}		

### If the account enable event is  following 	the account creation event  in the same time, then skip the event ###
elseIf (   $_.id -eq 4722    -AND   (  ($AccOpIsoEvents | ? { $_.id -eq 4720 }).TimeCreated  )  -match $_.TimeCreated )
		{
		$SkipEvent = 1;
		}

### If the 'Add to security Group' event is following the account creation event in the same time, then skip the event ###
elseIf (   $_.id -eq 4732    -AND   (  ($AccOpIsoEvents | ? { $_.id -eq 4720 }).TimeCreated  )  -match $_.TimeCreated )
		{
		$SkipEvent = 1;
		}

### If the 'Reset Password' event is following the account creation event in the same time, then skip the event ###
elseIf (   $_.id -eq 4724    -AND   (  ($AccOpIsoEvents | ? { $_.id -eq 4720 }).TimeCreated  )  -match $_.TimeCreated )
		{
		$SkipEvent = 1;
		}
		
## Skip if the event 4732 (Removing Account from Security Group) is followed by account deletion event (ie. both events have same date/time stamp)
elseIf (   $_.id -eq 4733    -AND   (  ($AccOpIsoEvents | ? { $_.id -eq 4726 }).TimeCreated  )  -match $_.TimeCreated )	
	{  $SkipEvent = 1; }		

### If the event id is 4781 then it's renaming the account ###
elseif ( $_.id -eq 4781)
	{
	$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingAcc = "Yes"
		}
		catch {
			$obj.TargetAccount = $SID
			$obj.ExistingAcc = "No"
		}
	### Get the old account and new account values ###
	$OldAccountName = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+3].split(":")[1].Trim()
	$NewAccountName = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+4].split(":")[1].Trim()
	$obj.ChangedValue = @("Old Account Name:$OldAccountName" , "New Account Name:$NewAccountName")		## Create the array and insert into object's attribute
	}

elseif ($_.id -eq 4723)
	{
	$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingAcc = "Yes"
		}
		catch {
			Try {
			$obj.TargetAccount = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+2].split(":")[1].Trim()
			$obj.ExistingAcc = "No"
			}
			catch {
			$obj.TargetAccount = $SID
			$obj.ExistingAcc = "No"
			}
		}
	}
	
### If the event id is 4732 or 4733 then it's adding/removing account to/from security group ###
elseIf   ($_.id -eq 4732 -OR $_.id -eq 4733 )   
		{ 
		$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Member:")+1].split(":")[1].Trim()		## Find the SID from $_.Message (after "Member:" line)
			Try {
			$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value
			$obj.ExistingAcc = "Yes"
			}
			catch {
				Try {
					$obj.TargetAccount = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Member:")+1].split(":")[2].Trim()			## If the SID is not found, then look at the 2nd line after "Member:" and add the local computer name prefix
					$obj.ExistingAcc = "No"
					}
				catch {
					$obj.TargetAccount = $SID
					$obj.ExistingAcc = "No"
				}
			}
		### Find the Target Group from $_.Message ####
		$SID  = ($_.Message -split "\n")[($_.Message -split "\n").Trim().IndexOf("Group:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetGroup = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingGrp = "Yes"
		}
		catch {
				Try {
				$obj.TargetGroup = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Group:")+2].split(":")[1].Trim()
				$obj.ExistingGrp = "No"
				}
				catch {
				$obj.TargetGroup = $SID
				$obj.ExistingGrp = "No"
				}
			}
		} 

elseif ( $_.id -eq 4731)	
		{	## If the event id is 4731, then it's about creating new security group ##
		$SID  = ($_.Message -split "\n")[($_.Message -split "\n").Trim().IndexOf("New Group:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetGroup = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingGrp = "Yes"
		}
		catch {
				Try {
				$obj.TargetGroup = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("New Group:")+2].split(":")[1].Trim()
				$obj.ExistingGrp = "No"
				}
				catch {
				$obj.TargetGroup = $SID
				$obj.ExistingGrp = "No"
				}
			}
		}

elseif ( $_.id -eq 4734)	
		{	## If the event id is 4734, then it's about creating new security group ##
		$SID  = ($_.Message -split "\n")[($_.Message -split "\n").Trim().IndexOf("Group:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetGroup = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingGrp = "Yes"
		}
		catch {
				Try {
				$obj.TargetGroup =  $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Group:")+2].split(":")[1].Trim()
				$obj.ExistingGrp = "No"
				}
				catch {
				$obj.TargetGroup = $SID
				$obj.ExistingGrp = "No"
				}
			}
		}
		
else {   
		### For the other events, normally insert value for 'Target Account', 'Existing Account' check and so on ###
		$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+1].split(":")[1].Trim()
		Try {
		$obj.TargetAccount = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
		$obj.ExistingAcc = "Yes"
		}
		catch {
			Try {
			$obj.TargetAccount = $env:computername+'\'+($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Target Account:")+2].split(":")[1].Trim()
			$obj.ExistingAcc = "No"
			}
			catch {
			$obj.TargetAccount = $SID
			$obj.ExistingAcc = "No"
			}
		}
		
		If ($_.id -eq 4738)	## If the event id is 4738, we need to output the changed attributes ###
			{
		### If the right side of 'User Account Control:'  in $_.Message is  blank then the return value will be -1  and  if so, we'll only output the changed attributes ###
			if ( ($_.Message -split "\n").Trim().IndexOf("User Account Control:") -eq -1 )
				{
				### List all changed attributes ###
				$StartIndex = ($_.Message -split "\n").Trim().IndexOf("Changed Attributes:")
				$ChangedAttrMsg = ($($StartIndex+1))..$($StartIndex+18) | foreach { ($Message -split "\n")[$_] }
				$obj.ChangedValue = $ChangedAttrMsg  | foreach { $_.split('',[System.StringSplitOptions]::RemoveEmptyEntries) -join "" }
				$obj.AccountOperation = "Attributes Changed"
				}
			else
				{	## If the right side of 'User Account Control' exists, then we have to loop the lines starting from 'User Account Control' + 1
					$StartIndex = ($_.Message -split "\n").Trim().IndexOf("User Account Control:")	## Get the location of the 'User Account Control:'  to start the loop from
					$Offset = ($_.Message.split("`n")).Trim().indexOf("Additional Information:")  - 33		## The total lines of $_.Message up to 'Additional Information' is 33, the subtracted value is number of lines to output, starting from 'User Account Control'  + 1
					$ChangedUacMsg = ($($StartIndex+1))..$($StartIndex+$Offset) | foreach { ($Message -split "\n")[$_] }		## Get the required message to output
					$obj.ChangedValue = $ChangedUacMsg  | foreach { $_.split('',[System.StringSplitOptions]::RemoveEmptyEntries) -join "" }		##  we have to eliminated white spaces in each line
					$obj.AccountOperation = "UAC Changed"
				}
			}
	}

If (!($SkipEvent))		## Check to skip the current event and if not, continue adding current object into $objs  ###
	{
	#### Find the account that initiates ####
	$InitiatorSID = ($_.Message -split "\n")[($_.Message -split "\n").Trim().IndexOf("Subject:")+1].split(":")[1].Trim()
	$SID = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Subject:")+1].split(":")[1].Trim()
			Try {
			$obj.InitiatedBy  = (New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate( [System.Security.Principal.NTAccount]).Value	
				}
			catch {
				Try {
				$obj.InitiatedBy = ($Message -split "\n")[($Message -split "\n").Trim().IndexOf("Subject:")+2].split(":")[1].Trim()
				}
				catch {
				$obj.InitiatedBy = $SID
				}
			}
$objs += $obj | select DateTime,AccountOperation,ID,TargetAccount,ExistingAcc,InitiatedBy,TargetGroup,ExistingGrp,ChangedValue 		## Collect the objects into object array
	}
}

$objs | sort DateTime -desc

Stop-Transcript
