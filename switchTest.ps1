$a = 4;

switch ($a) {
   1 { Write-Host "a 1 was put" }
   2 { Write-Host "a 2 was put" }
   3 { Write-Host "a 3 was put" }
   4 { Write-Host "a 4 was put" }
   5 { Write-Host "a 5 was put" }
   6 { Write-Host "a 6 was put" }
   4 { Write-Host "this is the seccond 4 block" }
   $true { Write-Host "this should always display" }
   Default { Write-Host "this is the default one" }
}

