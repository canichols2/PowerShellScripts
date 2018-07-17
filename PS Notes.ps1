$MyInvocation.MyCommand.Source
$TagSharpDLL=Join-Path (Split-Path $MyInvocation.MyCommand.Source -Parent) 'taglib-sharp.dll'
[System.Reflection.assembly]::LoadFile($TagSharpDLL)>$null
$PhotoTags= [TagLib.File]::Create('c:\Some\Dir\To\Jpg.jpg')
$PhotoTags.Tag.DateTime