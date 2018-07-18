function Import-Photos {
    param (
        $SourceFolder,
        $DestinationFolder,
        [switch]$Move
    )
    #######Support -WhatIf
    #######Support -Verbose
    
    # Read out where photos will go
    # list files from import photo directory/file
    # Copy files to new dir
    # Group photos by meaningful date ranges
    # Run file rename on new dir
}

function Rename-Photos {
    param (
         $SourceFolder
        ,[switch]$Recurse
        ,$NameRoot  # Folder where naming begins
        ,$Separator="-" # Character used to separate elements in filename, defaults to "-",
        ,[Switch]$Force # Switch to Rename ALL in source folder
    )
    #######Support -WhatIf
    #######Support -Verbose
    #######Validate Separator
    # Read out where photos will go
    # list out files in path
    # if not Force
    # # Isolate files not renamed yet.
    # rename selected files to folder Dir.
    Write-Output $Force;
}