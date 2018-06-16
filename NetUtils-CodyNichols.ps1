#===================================================

# Program Name : Netutils

# Author: Cody Nichols

# I Cody wrote this script as original work completed by me.

# Your Network Utility: <describe your network utility here>

# Support functions: Describe your network support functions.

#===================================================

# COMPLETED
function Test-IPHost{
   param(
      [Parameter(Mandatory=$True,Position=1)]
      [string]$HostName,
      $Count = 4
   )
   # $dns=Resolve-DnsName byui.edu |? {$_.gettype() -eq }
   $adds = @()
   $adds = Get-IpAddressesOfHostname $HostName
   $adds.length
   $adds|%{
      # echo $_
      Test-Connection $_ -Count $Count
   }
}
function toBinary($decimal){
   [string]$b = [convert]::ToString([int32]$decimal,2)
   $b.PadLeft(8,'0')
}
function toDecimal($binary){
   [string]$d=[convert]::ToInt32($binary,2)
   $d
}
function get-BinaryDottedString{
   param($thing)
   if($thing -match "^[\\/]?(\d{2})$"){
      # "Thing: $thing"
      $thing = $thing.replace("\","")
      $thing = $thing.replace("/","")
      # "Thing: $thing"
      $thing = [int]$thing
      # "Thing: $thing"
      $str = "","","",""
      $p=0
      for ($i = 0; $i -lt 8*4; $i++) {
         # "p:$p i:$i "
         if($i % 8 -eq 0 -and -not $i -eq 0){
            $p++
         }
         if($i -lt $thing){
            $str[$p] += "1"
         }

         else {
            $str[$p]+="0"
         }
      }
      return $str -join ('.')
   } else {
      # "Thing: $thing"
      $a,$b,$c,$d = $thing.split('.')
      # "Thing: $thing"
      "$(toBinary $a).$(toBinary $b).$(toBinary $c).$(toBinary $d)"
   }
}


function Test-IPNetwork{
   param(
      [Parameter(Mandatory=$True,Position=1)]
      $IP1, 
      [Parameter(Mandatory=$False,Position=2)]
      $IP2, #:  IP addresses to test
      [Parameter(Mandatory=$True,Position=3)]
      $SubnetMask #:  Subnet mask to use in tests
   )
   $SubnetMask =   $SubnetMask
   $ip1Sub = $SubnetMask
   $ip2Sub
   if(-not $SubnetMask){
      # //Get subnet mask from IP1 CIDER
      # throw "No subnet mask"
      #Else
      # //Get subnet mask from IP1 ClassFull
   }


   # CIDER was given
   # The ForEach is so you can pass in an array to IP1
   # NOT ACTUALLY NEEDED...................................
   $IP1 = $IP1 | ForEach-Object { ($_.split('/'))[0] } #; $IP1
   if($IP1.gettype().BaseType -eq [System.Object] 
    #  -and $IP2.gettype().BaseType -eq [System.Object]
   ){
      $IP1 = $IP1,($IP2.split('/'))[0]
   }
   if(Valid-Network $IP1[0] -and Valid-Network $IP1[1] )
   {
      $BinaryIP="",""
      $BinarySub   = get-BinaryDottedString $SubnetMask
      $BinaryIP[0] = get-BinaryDottedString $IP1[0]
      $BinaryIP[1] = get-BinaryDottedString $IP1[1]
      $BinarySub  
      $BinaryIP[0]
      $BinaryIP[1]
      for ($i = 0; $i -lt $BinarySub.length; $i++) {
         if($BinarySub[$i] -eq '1'){
            # "Checking $($BinaryIP[0][$i]) -eq $($BinaryIP[1][$i])"
            if($($BinaryIP[0][$i]) -eq $($BinaryIP[1][$i])){
               # "$($BinaryIP[0][$i]) Equals $($BinaryIP[1][$i])"
            }else{
               return $False
            }
         }
         
      }
      return $True;
      
      


   }
   else{
      throw "Not an IP Address"
   }
}
function Valid-Network($net)
{
   $net -match [ipaddress]$net
}

function Get-IPNetID {
   param($IP,$Sub)
   $BinaryIP = get-BinaryDottedString $ip
   if(-not $sub){
      if($BinaryIP[0] -eq '0')      {
         # Class A Network
         $BinarySub = get-BinaryDottedString "255.0.0.0"
      }
      elseif($BinaryIP[1] -eq '0')  {
         # Class B Network
         $BinarySub = get-BinaryDottedString "255.255.0.0"
      }
      elseif($BinaryIP[2] -eq '0')  {
         # Class C Network
         $BinarySub = get-BinaryDottedString "255.255.255.0"
      }
   }else{$BinarySub = get-BinaryDottedString $sub}
   $BinaryNetID = ""
   for ($i = 0; $i -lt $BinarySub.length; $i++) {
      if($BinarySub[$i] -eq '1' -or $BinarySub[$i] -eq '.' )
      {
         $BinaryNetID += $BinaryIP[$i]
      }else{
         $BinaryNetID += "0"
      }
   }
}


function Get-IpAddressesOfHostname ([Parameter(Mandatory=$True)]$hostname)  {
   (Resolve-DnsName -Name $hostname |?{($_.gettype()).name -eq 'DnsRecord_a'} | %{$_}).IPAddress
}

function Get-ClassFullNetwork{

}

function Test-ValidIPAddress ($IPAddress) {
   
}




# Personal function