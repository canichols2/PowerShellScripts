#===================================================
# Program Name : PhotoModule
# Author: Cody Nichols
# I Cody wrote this script as original work completed by me.
# SYNOPSYS:
#     Import-Photos:
#        Instructions say to set destination folder as current if omitted. 
#        I don't understand that use case, so I made a default destination folder that made sense to me.
#     
#===================================================
$script:DestinationFolder = "$env:USERPROFILE\Pictures\Organized"
$script:ModuleFile = $MyInvocation.MyCommand.Source
$script:ModuleFolder = $(Get-ChildItem $MyInvocation.MyCommand.Source).DirectoryName
$script:myFolderCommand = $MyInvocation.MyCommand
$script:myFolder = $MyInvocation

$TagSharpDLL=Join-Path $script:ModuleFolder 'taglib-sharp.dll'
[System.Reflection.assembly]::LoadFile($TagSharpDLL)>$null

# Helper Methods
function tag {
   param (
      $path
   )
   [TagLib.File]::Create($path)
}
function getYear {
   param ($file)
   $tags=tag $file
   if($tags.tag.datetime){
      return $tags.tag.datetime.year
   }else{
      return $file.CreationTime.year
   }
}
function getMonth {
   param ($file)
   $tags=tag $file
   if($tags.tag.datetime){
      return $tags.tag.datetime.Month
   }else{
      return $file.CreationTime.Month
   }
}
function getDay {
   param ($file)
   $tags=tag $file
   if($tags.tag.datetime){
      return $tags.tag.datetime.Day
   }else{
      return $file.CreationTime.Day
   }
}


# Exported Methods

function Import-Photos {
   <#
  .SYNOPSIS
  You specify what directory to import, it imports and sorts the files
  .DESCRIPTION
  Imports photos to default folder in userprofile pictures and sorts them by year/month/day
  .EXAMPLE
  Import-Photos $pwd
  .EXAMPLE
  Import-Photos $pwd -Move
      This will remove the pictures from the source.
  .PARAMETER computername
  Import-Photos $pwd -DestinationFolder "C:\Pictures\NewFolder\etc"
      This will specify a new destination instead of the defaut in my pictures.
  #>
  [CmdletBinding(SupportsShouldProcess=$True)]
   param (
      $SourceFolder,
      $DestinationFolder="$env:USERPROFILE\Pictures\Imported",
      [switch]$Move=$false
   )
   #######Support -WhatIf
   #######Support -Verbose
   
   # TODO:Read out where photos will go
   # TODO:list files from import photo directory/file
   $importFiles =  Get-ChildItem -Recurse $SourceFolder -Filter *.jpg
   $importFiles += Get-ChildItem -Recurse $SourceFolder -Filter *.png
   $importFiles += Get-ChildItem -Recurse $SourceFolder -Filter *.jpeg

   # $tagsArr = @();
   foreach ($picture in $importFiles) {
      #  $tags
      $Year = getYear $picture
      $Month = getMonth $picture
      $Day = getDay $picture
      # DONE:Copy files to new dir
      If ($PSCmdlet.ShouldProcess($picture.name,"Moving to $DestinationFolder\$year\$Month\$Day\")) {
         Copy-Item $picture.FullName "$DestinationFolder\$year\$Month\$Day\" -Force
      }
      if($move){
         If ($PSCmdlet.ShouldProcess($picture.name,'Removing-Item')) {
            remove-item $picture
         }
      }
   }
   return $tagsArr
   # TODO:Group photos by meaningful date ranges
   # DONE:Run file rename on new dir
   Rename-Photos -SourceFolder $DestinationFolder -NameRoot $DestinationFolder -Recurse 
}


function Rename-Photos {
   <#
  .SYNOPSIS
  Renames files in folders based on folder structure
  .DESCRIPTION
  You specify a folder to rename files in, and specify where the naming convention starts and all the folders inbetween get put into the file name of the files.
  .EXAMPLE
  Rename-Photos -SourceFolder C:\Users\admin\Pictures\wallpaper\faccet -NameRoot C:\Users\admin\Pictures\
      all files in "faccet" will be renamed to have "wallpaper-faccet-00012.jpg" on it.
  .EXAMPLE
  Rename-Photos -SourceFolder C:\Users\admin\Pictures\wallpaper\faccet -NameRoot C:\Users\admin\Pictures\ -separator "_"
      same as last but instead of dash it'll be an underscore.
   .EXAMPLE
  Rename-Photos -SourceFolder C:\Users\admin\Pictures\wallpaper\faccet -NameRoot C:\Users\admin\Pictures\ -Force
      The force parameter will force all files to be rewritten, and not just the ones that aren't already renamed.
  #>
  [CmdletBinding(SupportsShouldProcess=$True)]
   param (
       $SourceFolder
      ,[switch]$Recurse #Do we process subfolders
      ,$NameRoot  # Folder where naming begins
      ,$Separator="-" # Character used to separate elements in filename, defaults to "-",
      ,[Switch]$Force # Switch to Rename ALL in source folder
      ,$uniqueLength=5
   )
   #######Validate Separator
   if($Separator -match "[.&^#@*]"){throw "invalid separator";exit}
   function getSubPath($file){
      if($file.fullname.contains($NameRoot)){
         return $file.fullname.Replace($NameRoot,"")
      }else{
         throw "$($file.fullname) is not in folder $NameRoot"
      }
   }
   function notRenamed {param ($file)
      $count = $file -split('-') | select -Last 1 |   % {
         $_ -split('\.') | select -First 1 } | ? {
            $_.Length -eq $uniqueLength -and [int32]::TryParse($_,[ref]$tmp)}|measure
      if($count.Count -eq 0){return $true;}else{return $false}
   }
   $files = Get-ChildItem $SourceFolder -Recurse:$Recurse
   [int]$tmp = 0
   $intValues = $files | %{
       $_ -split('-') | select -Last 1} |   % {
           $_ -split('\.') | select -First 1 } | ? {
              $_.Length -eq $uniqueLength -and [int32]::TryParse($_,[ref]$tmp)} 
   $currentHighest = $intValues |%{[int]$_}|sort|select -last 1
   foreach ($file in $files) {
      $subpath = getSubPath $file
      $fileType = $file.name -split('\.') | select -last 1
      $newFileName = $subpath -split('\\') 
      $l = $newFileName.Length - 2  #Cause for whatever reason... -1 still gave me ALL of them
      $newFileName = $newFileName[0..$l]
      $newFileName = $newFileName -join($Separator)
      if(notRenamed $file.name -or $Force){
         $currentHighest++
         $newFileName = $newFileName,$currentHighest.ToString().PadLeft($uniqueLength,"0")-join($Separator)
         $newFileName = "$newFileName.$fileType"
         If ($PSCmdlet.ShouldProcess($file.name,"Rename to $newFileName")) {
            Rename-Item $file $newFileName
         }
      }
   }



   # TODO: Read out where photos will go
   # TODO: list out files in path
   # if not Force
   # # TODO: Isolate files not renamed yet.
   # TODO: rename selected files to folder Dir.
}