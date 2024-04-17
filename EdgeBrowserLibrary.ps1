# Function that lists all Edge profiles for logged on user, with the relevant email address registered and full name
Function Get-CurrentUserEdgeProfiles {
    # This function reads the "Local State" JSON file from the Edge Browser config, located in "%env:LOCALAPPDATA%\Microsoft\Edge\User Data"
    # This file is in JSON format
    # Data gathered is extensive, so we only report back an object with:
    # - name: Usually "Default", "Profile 1"...
    # - shortcut_name: Contains an alias for the profile name
    # - gaia_name: Contains the user Full Name
    # - user_name: Contains the user name, matching an email address
    # - edge_sync_enabled: Contains the status of the sync configuration (Boolean)
    #
    # Data is verified with a REgistry query towards the profile configuration, located in:
    # Computer\HKEY_CURRENT_USER\Software\Microsoft\Edge\Profiles\<Profile ID>\OID

    # We set/define some variables here
    $EdgeRegistryPath = "HKCU:\Software\Microsoft\Edge\Profiles"
    $EdgeConfigJSON = ""
    $EdgeConfigFolder = "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data"
    $EdgeConfigFile = "Local State"
    $RegEdgeProfiles = $null
    $EdgeLocalStateData = $null
    $Output = @()

    # Read all data
    try {
        Write-Verbose "Reading Edge Registry data in $($EdgeRegistryPath)"
        $RegEdgeProfiles = Get-ChildItem -Path $EdgeRegistryPath -Recurse
    }
    catch {
        Write-Error "Failed to read Registry Path $($EdgeRegistryPath)"
        exit
    }

    try {
        Write-Verbose "Reading JSON config file '$($EdgeConfigFile)' in $($EdgeConfigFolder)"
        $EdgeLocalStateData = (Get-Content "$($EdgeConfigFolder)\$($EdgeConfigFile)" | Out-String | ConvertFrom-Json)
    }
    catch {
        Write-Error "Failed to read $($EdgeConfigFile) in $($EdgeConfigFolder)"
        exit
    }

    # Get the existing Edge Profiles from Edge Config file
    $EdgeJSONProfiles = $EdgeLocalStateData.profile.info_cache
    $foo = 1
    foreach ($EdgeJSONprofile in $EdgeJSONProfiles.PSObject.Properties) {
        # Verify if the profile also exists in the Registry
        if ($($EdgeJSONprofile.Name) -in ($RegEdgeProfiles.Name | Split-Path -Leaf)) {
            Write-Verbose "Profile $($EdgeJSONprofile.Name) exists in the Registry"

        }else{
            Write-Verbose "Profile $($EdgeJSONprofile.Name) does not exist in the Registry"
            break
        }
        # Reads bookmarks file size and defines a variable with it
        $bookmarks_filesize = $null
        $tempJSONData = $null
        $ProfileFolderName = $null
        if (Test-Path -Path "$($EdgeConfigFolder)\$($EdgeJSONprofile.Name)\Bookmarks") {
            $bookmarks_filesize = (Get-Item "$($EdgeConfigFolder)\$($EdgeJSONprofile.Name)\Bookmarks").Length
        }
        Write-Verbose "Reading profile $($EdgeJSONprofile.Name) from Edge Config File"
        Write-Verbose "Capturing JSON data"
        $tempJSONData = $EdgeLocalStateData.profile.info_cache.$($EdgeJSONprofile.Name)
        Write-Verbose "Reading Profile Name from Registry"
        #$tempJSONData
        # Store all data in an object
        $output += new-object psobject -property @{name=$tempJSONData.name; shortcut_name=$tempJSONData.shortcut_name; gaia_name=$tempJSONData.gaia_name; user_name=$tempJSONData.user_name; edge_sync_enabled=$tempJSONData.edge_sync_enabled; path="$($EdgeConfigFolder)\$($EdgeJSONprofile.Name)"; bookmarks_size=$bookmarks_filesize; OID=$tempJSONData.edge_account_oid}
    }
    return $Output
}

function Get-EdgeProfileNameByOID {
    # This function receives an OID (identifier of an Edge profile)
    # and outputs the profile name found in registry for that OID
    # it returns $null if no profile is found

    [CmdletBinding()] 
    param( 
    [string]$OID
    )

    # We set/define some variables here
    $EdgeRegistryPath = "HKCU:\Software\Microsoft\Edge\Profiles"
    $output = $null

    # Read all data
    try {
        Write-Verbose "Reading Edge Registry data in $($EdgeRegistryPath)"
        $RegEdgeProfiles = (Get-ChildItem $EdgeRegistryPath | Get-ItemProperty)
    }
    catch {
        Write-Error "Failed to read Registry Path $($EdgeRegistryPath)"
        exit
    }

    foreach ($RegEdgeProfile in $RegEdgeProfiles) {
        if ($OID -eq $($RegEdgeProfile.OID)) {
            $output = $($RegEdgeProfile.PSChildName)
        }
    }
    return $output
}


Get-CurrentUserEdgeProfiles
