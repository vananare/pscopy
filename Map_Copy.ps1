$Object =@() 
$Computername=Get-Content("C:\temp\Compuetrs.txt")
#get computers list here
###get credentails######
$creds_d = Get-Credential -Message "Enter crdetial to map drive with domain" 
$Drive = "\\127.0.0.1\MyTest1"
$Letter = "k"
####---------------####



$Scriptcode ={
New-PSDrive -Name $Letter -PSProvider "FileSystem" -Root $Drive -Credential $creds_d -ErrorAction Stop;

Start-Sleep 5;

Copy-Item -Path "$Letter\*" -Destination "E:\GCTI\software\" -Recurse;

start-sleep 5;

Remove-PSDrive -Name $Letter;

}

Foreach($EachServer in $Computername){
    Write-Host "Working on $EachServer"
    if(Test-Connection -ComputerName $EachServer -Count 2 -Quiet)
    {
        try{
        Invoke-Command -ComputerName $EachServer -ScriptBlock $Scriptcode -ErrorAction Stop
        $dirSize = Get-ChildItem "\\$EachServer\E$\GCTI\Software" -recurse -force | select Length  |Measure-Object -Sum
        $dirSize = $dirSize.sum/1MB
        $op = "Copied - $dirSize"
        }
        catch [Exception] {
         $op = $_.Exception.Message
        }
        
        $Object = New-Object PSObject -Property @{
                HostName = $EachServer
                Status = "Pinging"
                Files = $op
            }

        $Object |Export-Csv -Path "c:\temp\Output.csv" -Append -Force

    }
    Else{

    $Object = New-Object PSObject -Property @{
            HostName = $EachServer
            Status = "Not Pinging"
            Files = "Not copied"
           }

    $Object |Export-Csv -Path "c:\temp\Output.csv" -Append -Force

    }
}
