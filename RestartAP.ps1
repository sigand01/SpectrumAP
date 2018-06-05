# Made by admsha
Param(
  [String]$ip,
  [String]$APname
)


Function Restart-AP(){

    $stream.Write("reload`n")
    start-sleep -Seconds 1
    $stream.Read()
    $stream.Write("yes`n")
    Start-Sleep -Seconds 1
    $stream.Read()
    $stream.Write("`n")

}

$username = "admin"
$pass = "Rt8Oa"
$Credpass = ConvertTo-SecureString -String $pass -AsPlainText -Force
$APCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $Credpass

$accessAPSession = New-SSHSession -ComputerName "$ip" -Credential $APCreds -AcceptKey
$stream =  $accessAPSession.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)

Start-Sleep 1
$stream.Write("en`n")
start-sleep -Seconds 1
$stream.Read()
$stream.Write("$pass`n")
start-sleep -Seconds 1
$stream.Read()

#Henter og lagrer logg før restart
[String]$output = ""
write-host "Saving logg..."
$stream.Write("show logg`n")
Start-Sleep -Milliseconds 500

while($stream.Length -ne 1){

    $output += Out-String -InputObject $stream.Read()
    $stream.Write(" ")
    Start-Sleep -Milliseconds 25

}
$output | Out-File -FilePath D:\APlogs\$APname"-restart".txt

#Sjekker AP modell da det er nødvendig å aktivere debug før reload på visse modeller
$stream.Write("sh version | in Product/Model`n")
Start-Sleep  1
$modell = $stream.Read() | Out-String

if( $modell.Contains("AIR-CAP1602") -or 
    $modell.Contains("AIR-CAP1702") -or
    $modell.Contains("AIR-CAP2702") -or
    $modell.Contains("AIR-CAP3602")){
    
    $modell
    $stream.Write("debug all`n")
    Start-Sleep 1
    $stream.Write("yes`n")
    Start-Sleep 1
    Write-Host "Restarter $APname..."
    Restart-AP
}
else{
    
    $modell
    Write-Host "Restarter $APname..."
    Restart-AP

}
$stream.Close()
Write-Host "Done"





