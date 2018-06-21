#===================================================

# Program Name : Netutils

# Author: Cody Nichols

# I Cody wrote this script as original work completed by me.

# Your Network Utility: <describe your network utility here>

# Support functions: Describe your network support functions.

#===================================================

# COMPLETED
function toBinary($decimal){
   [string]$b = [convert]::ToString([int32]$decimal,2)
   $b.PadLeft(8,'0')
}
function toDecimal($binary){
   [string]$d=[convert]::ToInt32($binary,2)
   $d
}

function get-IPandSubnet{
   param(
      $IP,
      [switch]$BinarySub=$false,
      [switch]$BinaryIP=$false
   )
   if($IP -match "^\d{1,3}(.(\d){1,3}){3}/\d{1,2}$"){
      $IP,$SUB = $IP.split('/')
      $IPBinary=get-BinaryDottedString $IP
      $SUBBinary=get-BinaryDottedString $SUB
   }
   elseif($IP -match "^\d{1,3}(.(\d){1,3}){3}$"){
      $IPBinary = get-BinaryDottedString $IP
      if(-not $sub){
         if($IPBinary[0] -eq '0'){
            # Class A Network
            $SUBBinary = get-BinaryDottedString "255.0.0.0"
         }
         elseif($IPBinary[1] -eq '0'){
            # Class B Network
            $SUBBinary = get-BinaryDottedString "255.255.0.0"
         }
         elseif($IPBinary[2] -eq '0'){
            # Class C Network
            $SUBBinary = get-BinaryDottedString "255.255.255.0"
         }
      }
   }
   # "IP: $IP"
   # "CIDR: $SUB"
   $SUB = Convert-BinaryNetToDecimal $SUBBinary
   # "SUB: $SUB"
   # "IPBinary: $IPBinary"
   # "SUBBinary: $SUBBinary"
   if($binarySub -and $BinaryIP){
      return $IPBinary,$SUBBinary
   }
   elseif(-not $binarySub -and $BinaryIP){
      return $IPBinary,$SUB
   }
   elseif($binarySub -and -not $BinaryIP){
      return $IP,$SUBBinary
   }
   elseif(-not $binarySub -and -not $BinaryIP){
      return $IP,$SUB
   }
}

function get-BinaryDottedString{
   param($IPAddress, $cider, $Subnet)
   if (-not $IPAddress) {
      if ($cider) {
         $IPAddress = $cider
      }
      else {
         $IPAddress = $Subnet
      }
   }
   if($IPAddress -match "^[\\/]?(\d{2})$"){
      $IPAddress = $IPAddress.replace("\","")
      $IPAddress = $IPAddress.replace("/","")
      $IPAddress = [int]$IPAddress
      $str = "","","",""
      $p=0
      for ($i = 0; $i -lt 8*4; $i++) {
         # "p:$p i:$i "
         if($i % 8 -eq 0 -and -not $i -eq 0){
            $p++
         }
         if($i -lt $IPAddress){
            $str[$p] += "1"
         }

         else {
            $str[$p]+="0"
         }
      }
      return $str -join ('.')
   } elseif($IPAddress -match "^\d{1,3}(.(\d){1,3}){3}$") {
      $a,$b,$c,$d = $IPAddress.split('.')
      "$(toBinary $a).$(toBinary $b).$(toBinary $c).$(toBinary $d)"
   }else {
      throw "incorrect formatting of IP or Cider"
   }
}


function Valid-Network($net){
   $net -match [ipaddress]$net
}
function Convert-BinaryNetToDecimal{
   param($BinaryNet)
   $( $( $BinaryNet.split(".")) | % { toDecimal $_ }) -join ('.')
}

function Get-IpAddressesOfHostname ([Parameter(Mandatory=$True)]$hostname)  {
   (Resolve-DnsName -Name $hostname |?{($_.gettype()).name -eq 'DnsRecord_a'} | %{$_}).IPAddress
}

function Get-ClassFullNetwork{

}

function Test-ValidIPAddress ($IPAddress) {
   
}

function Get-ClassfullSubnet{
   param($IP,$BinaryIP)
   if(-not $IP){if(-not $BinaryIP){throw "IP Address Required"}}
   if(-not $BinaryIP){$BinaryIP = get-BinaryDottedString $IP}
   if($BinaryIP[0] -eq '0')      {
      # Class A Network
      $SUB =  "255.0.0.0"
   }
   elseif($BinaryIP[1] -eq '0')  {
      # Class B Network
      $SUB =  "255.255.0.0"
   }
   elseif($BinaryIP[2] -eq '0')  {
      # Class C Network
      $SUB =  "255.255.255.0"
   }else{
      throw "Not a Class A, B or C Network"
   }
   if($Binary){
      return get-BinaryDottedString $SUB
   }
   return $SUB
   
}


# Exported Functions
function Test-IPHost{
   param(
      [Parameter(Mandatory=$True,
      ValueFromRemainingArguments=$true)]
      [string[]]$HostName,
      $Count = 4
   )
   foreach ($Host in $HostName) {
      $adds = @()
      $adds = Get-IpAddressesOfHostname $Host
      $adds.length
      $adds|%{
         # echo $_
         Test-Connection $_ -Count $Count
      }
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

   $IP1 = $IP1 | ForEach-Object { ($_.split('/'))[0] } #; $IP1
   if($IP1.gettype().BaseType -eq [System.Object] 
    #  -and $IP2.gettype().BaseType -eq [System.Object]
   ){
      $IP1 = $IP1,($IP2.split('/'))[0]
   }
   if(Valid-Network $IP1[0] -and Valid-Network $IP1[1] )
   {
      # $BinaryIP="",""
      # $BinarySub   = get-BinaryDottedString $SubnetMask
      # $BinaryIP[0] = get-BinaryDottedString $IP1[0]
      # $BinaryIP[1] = get-BinaryDottedString $IP1[1]
      $BinaryNetID="",""
      $BinaryNetID[0] = Get-IPNetID $IP1[0] $SubnetMask -Binary
      $BinaryNetID[1] = Get-IPNetID $IP1[1] $SubnetMask -Binary
      if($BinaryNetID[0] -eq $BinaryNetID[1]){
         return $True;
      }else {
         return $False
      }
   }
   else{
      throw "Not an IP Address"
   }
}

function Get-IPNetID {
   param($IP,$SubnetMask,[switch]$Binary = $False)
   # "IP:  $IP"
   # "SUB: $SubnetMask"
   if(-not $SubnetMask){ $IP,$SubnetMask = get-IPandSubnet $IP}
   $BinaryIP = get-BinaryDottedString $ip
   # "IP:  $IP"
   # "SUB: $SubnetMask"
   if(-not $SubnetMask){
      $BinarySub = Get-ClassfullSubnet -Binary -IP $IP -BinaryIP $BinaryIP
   } else {
      $BinarySub = get-BinaryDottedString $SubnetMask
   }
   $BinaryNetID = ""
   for ($i = 0; $i -lt $BinarySub.length; $i++) {
      if($BinarySub[$i] -eq '1' -or $BinarySub[$i] -eq '.' )
      {
         $BinaryNetID += $BinaryIP[$i]
      }else{
         $BinaryNetID += "0"
      }
   }
   if($Binary){return $BinaryNetID}
   $DecimalNetID = Convert-BinaryNetToDecimal $BinaryNetID
   $DecimalNetID
}

Export-ModuleMember -Function get-IPandSubnet,Get-IPNetID,Test-IPNetwork,Test-IPHost