# Made by admsha
Param(
  [String]$ip,
  [String]$APname
)

#Funksjon søker etter "keyword" i logg
function Find-Errors($keyword, $logoutput){

    $ut = $logoutput.Replace("--More--","")
    #$ut = $ut.Replace($ut.Substring(0, ($ut.IndexOf("bytes):"))+7) ,"")
    $ut2 = $ut -split '[\r\n]'
    $errors = @()

foreach($line in $ut2){
    
    if($line.Contains($keyword)){
        
        $errors += $line
        Write-Host $line

    }else{
    
        Write-Host $line

    }
   }
   if($errors){
    Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>FOUND ERRORS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    Write-Host ""
    $errors
    
   }else{Write-Host ">>>>>>>>>>>>>>>>>>NO KNOWN ERRORS FOUND<<<<<<<<<<<<<<<<<<<<<<<<<<<"}

}

$username = "admin"
$pass = "Rt8Oa"
$Credpass = ConvertTo-SecureString -String $pass -AsPlainText -Force
$APCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $Credpass

$accessAPSession = New-SSHSession -ComputerName "$ip" -Credential $APCreds -AcceptKey
$stream =  $accessAPSession.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)

start-sleep 1
[String]$output = ""
$stream.Write("en`n")
start-sleep 1
$stream.Read()
$stream.Write("$pass`n")
start-sleep 1
$stream.Read()
Start-Sleep -Milliseconds 500
$stream.Write("show logg`n")
Start-Sleep -Milliseconds 500

#Løkke som løper gjennom stream output ved å sende "space" kommando fram til stream.length er "tom"
while($stream.Length -ne 1){

$output += Out-String -InputObject $stream.Read()
$stream.Write(" ")
Start-Sleep -Milliseconds 25

}

start-sleep -Milliseconds 500
$stream.Write("exit`n")
$stream.Close()

#Find-Errors "MIC failure hold state" $output
$output

$output | Out-File -FilePath D:\APlogs\$APname.txt
