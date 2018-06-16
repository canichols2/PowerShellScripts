#============================================================
# Program Name: Color
# Author: Cody Nichols
# I, Cody Wrote this script as original work completed by me.
# Special Feature: ETC.ETC.ETC. ETC.ETC.
#============================================================

function nbg($color){
if($Host.UI.RawUI.BackgroundColor -eq $color) {
        $en = ([System.ConsoleColor] $color) + 1
        if ( $en.value__ -eq 15)
        {
            $en = ([System.ConsoleColor] )
        }
        $en
    } else { $Host.UI.RawUI.BackgroundColor}
}


function round()
{
      $startTime = [DateTime]::Now
      $guesses = @();
      $Colors = ([enum]::GetValues([System.ConsoleColor])) ;
      $answer = $Colors[ $(Get-Random -Minimum 0 -Maximum $Colors.Length) ]
   function GetInput()
   {
      Write-Host -NoNewline "Possible Answers: ["
      [ConsoleColor] $ParseVar = 4
      # Write-Host "Writing to host"
      ([enum]::GetValues([System.ConsoleColor]))  | % {
         if($_ -notin $guesses)
         {
            $newbg = nbg($_)
            if($_ -in $Colors) {
               Write-Host -NoNewline -ForegroundColor $_ "$_"  -BackgroundColor $newbg         
            }
            else {
               Write-Host -NoNewline "$_"  -BackgroundColor $newbg
            }
            Write-Host -NoNewline "," 
         }
      };
      Write-Host "]"
      Write-Host "Your Guesses:     [ " -NoNewline
      $guesses | %{
         $newbg = if($Host.UI.RawUI.BackgroundColor -eq $_) {
            $en = ([System.ConsoleColor] $_) + 1
            if ( $en.value__ -eq 15)
            {
               $en = ([System.ConsoleColor] )
            }
            $en
         } else { $Host.UI.RawUI.BackgroundColor}
         if($_ -in $Colors) {
            Write-Host -NoNewline -ForegroundColor $_ "$_"  -BackgroundColor $newbg         
         }
         else {
            Write-Host -NoNewline "$_"  -BackgroundColor $newbg
         }
         Write-Host -NoNewline "," 
      }
      Write-Host            "]"
      return Read-Host ">"
   }

   do{
      $guess = GetInput;
      if($guess -eq 'exit')
         {return 'canceled';}
      $guesses += $guess
   }while ( $answer -ne $guess)

   write-host "Congratulations!!! $answer is my favorite color"

   $endTime = [DateTime]::Now
   Write-Host "It took you $($($endTime-$startTime ).minutes) minutes"
   return $($endTime-$startTime ).minutes
}



$games = @()
do {
   Write-Host @"
   Options:
      1) Play another round.
      2) Look at my history.
      E) Exit game.
"@
   $option = read-host ">"
   switch ($option) {
      1 {
         $games += round
         break;
      }
      2 { $games|%{$it=1}{ 
         Write-Host "Game $it " -NoNewline; 
         if($_.gettype() -eq [int32])
         { Write-Host "took $_ minutes"}
         else
         {
            Write-Host "was canceled."
         }
         break;
      }{} }
      'E'{exit }
      Default {}
   }
}while ($true)