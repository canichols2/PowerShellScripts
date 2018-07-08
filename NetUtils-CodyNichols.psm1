#===================================================

# Program Name : Netutils

# Author: Cody Nichols

# I Cody wrote this script as original work completed by me.

# Your Network Utility: Basic network functions from class. 
#        One netwok function that helps me so I can look at the Binary representation of things.

# Support functions: I have many support functions because
#     I wanted to modularize EVERYTHING so it is truely a DRY programming.
#     Function Help based on microsoft's https://technet.microsoft.com/en-us/library/hh360993.aspx?f=255&MSPPError=-2147217396 page.

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
function Get-SubFromCIDR{
   <#
   .SYNOPSIS
   Returns just the subnet from a cidr notation
   .DESCRIPTION
   Optionaly will give the Binary or Decimal representation of each
   .EXAMPLE
   Get-SubFromCIDR 192.168.18/25    
   .EXAMPLE
   Get-SubFromCIDR 192.168.18/25 -Decimal
   .EXAMPLE
   192.168.18/25 | Get-SubFromCIDR 
   .EXAMPLE
   192.168.18/25 | Get-SubFromCIDR -Binary
   .EXAMPLE
   192.168.18/25 | Get-SubFromCIDR -Decimal
   #>
   param(
      [parameter(ValueFromPipeline,Mandatory=$true)]$IP,
      [switch]$Binary,
      [switch]$Decimal
   )
   if($IP -match "^(\d{1,3}(.(\d){1,3}){3}){0,1}/\d{1,2}$"){
      $IP,$SUB = $IP.split('/')
      if($Decimal){
         # Cider to decimal...
         $BianryString = get-BinaryDottedString -cider $SUB
         $DecimalArray = $BianryString.split('.') | %{
            [convert]::ToInt32($_,2)
         }
         return $DecimalArray -join "."
      }
      if($Binary){
         return get-BinaryDottedString -cider $SUB
      }
      return $SUB
   }else{
      throw "Not CIDR"
   }
}
function Get-IPandSubnet{
   <#
   .SYNOPSIS
   Returns the IP and Subnet of an IP Address.
   .DESCRIPTION
   If you leave off the cider notation, it will give you the classfull network of the IP Address.
   Using the -BinarySub switch, you will get the subnet returned in a binary string.
   Using the -BinaryIP switch, you will get the IP Address returned in a binary string.
   Returns a string array with 2 elements. The first is the IP and the other is the Full Subnet.
   .EXAMPLE
   Get-IPandSubnet 192.168.18/25    
   .EXAMPLE
   192.168.18/25 | Get-IPandSubnet
   #>
   [CmdletBinding()]
   param(
      [parameter(ValueFromPipeline)]$IP,
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
   else{
      throw "No IP Address given, or wrong format."
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
   <#
   .SYNOPSIS
   This will test every IP Address associated with a Fully Qualified Domain Name(FQDN)
   .DESCRIPTION
   You provide a FQDN and this queries nameservers to determine all IP Addresses associated with that hostname.
   .EXAMPLE
   Test-IPHost -HostName "Google.com" 
   .EXAMPLE
   "google.com" | Test-IPHost
   .EXAMPLE
   Test-IPHost -HostName "Google.com" -Count 2
   .EXAMPLE
   Test-IPHost -HostName "Google.com","www.microsoft.com","amazon.com"
   #>
   [CmdletBinding()]
   param(
      [Parameter(Mandatory=$True,
      ValueFromRemainingArguments=$true,
      ValueFromPipeline)]
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
   <#
   .SYNOPSIS
   This will test if IP's are in fact on the same network.
   .DESCRIPTION
   You can provide 2 IP addresses, and a subnet mask, or provide the netmask as CIDR notation in the first IP address. 
   This will return true or false depending on wether they are they same network or not.
   .EXAMPLE
   Test-IPNetwork 192.168.16.8 192.168.17.2 255.255.255.0
   .EXAMPLE
   Test-IPNetwork -IP1 192.168.16.8  -IP2 192.168.17.2  -SubnetMask 255.255.255.0
   .EXAMPLE
   Test-IPNetwork 192.168.16.8,192.168.17.2  -SubnetMask 255.255.255.0
   .EXAMPLE
   Test-IPNetwork -IP1 192.168.16.8,192.168.17.2  -SubnetMask 255.255.255.0
   #>
   [CmdletBinding()]
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
   [CmdletBinding(SupportsShouldProcess=$True)]
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

Export-ModuleMember -Function get-IPandSubnet,Get-IPNetID,Test-IPNetwork,Test-IPHost,Get-SubFromCIDR