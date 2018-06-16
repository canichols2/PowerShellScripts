
$defaultLanguage = 'who'

$lang = @{
   "en-us"="Hello";
   "en-gb"="'Ello";
   "spanish"="Hola";
   "Nichols"="Wut";
   "who"="Who are you";
}
function Hello
{
   Param($Firstname,$LastName, 
   [ValidateScript({$Script:lang.ContainsKey($_)})]
   $language
   )
   if( -not $language )
   {
      $language = $Script:defaultLanguage
   }

   Write-Host "$($lang[$language]) $firstname $LastName";
}

function set-defaultLanguage
{
   [ValidateScript({$lang.ContainsKey($_)})]
   Param($lang)
   $Script:defaultLanguage = $lang
}