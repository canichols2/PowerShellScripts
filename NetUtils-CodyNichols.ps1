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
function get-BinaryDottedString{
   param($thing)
   if($thing -like "[\\/]?(\d{2}"){
      $thing = $thing.replace("\","")
      $thing = $thing.replace("/","")
      $thing = [int]$thing
      $str = ""
      for ($i = 0; $i -lt 8*4; $i++) {
         if($i -lt $thing){
            $str += "1"
         }
         else {
            $str+="0"
         }
      }
      $str.split
   }
}


function Test-IPNetwork{
   param(
      [Parameter(Mandatory=$True,Position=1)]
      $IP1, 
      [Parameter(Mandatory=$False,Position=1)]
      $IP2, #:  IP addresses to test
      [Parameter(Mandatory=$False,Position=1)]
      $SubnetMask #:  Subnet mask to use in tests
   )
   $SubnetMask = get-BinaryDottedString $SubnetMask
   $ip1Sub = $SubnetMask
   $ip2Sub
   if(-not $SubnetMask){
      # //Get subnet mask from IP1 CIDER
      #Else
      # //Get subnet mask from IP1 ClassFull
   }


   # Sanatizes this into just IP Address if CIDER was given
   # The ForEach is so you can pass in an array to IP1
   # NOT ACTUALLY NEEDED...................................
   $IP1 = $IP1 | ForEach-Object { ($_.split('/'))[0] } #; $IP1
   if
      ($IP1.gettype().BaseType -eq [System.Object] 
    #  -and $IP2.gettype().BaseType -eq [System.Object]
   )
   {
      $IP1 = $IP1,($IP2.split('/'))[0]
   }
   if(Valid-Network $IP1[0] -and Valid-Network $IP1[1] )
   {
      
      


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
   
}


function Get-IpAddressesOfHostname ([Parameter(Mandatory=$True)]$hostname)  {
   (Resolve-DnsName -Name $hostname |?{($_.gettype()).name -eq 'DnsRecord_a'} | %{$_}).IPAddress
}

function Get-ClassFullNetwork{

}

function Test-ValidIPAddress ($IPAddress) {
   
}




# Personal function