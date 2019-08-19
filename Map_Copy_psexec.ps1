$Object =@() 
$Computername=Get-Content("C:\temp\Compuetrs.txt")
#get computers list here
###get credentails######
$PSExec = "C:\temp\PSExec.exe"
$user_d = Read-Host -Prompt "Enter username to map drive"
$pswd_d = Read-Host -Prompt "Enter password to map drive"
$Drive = "\\127.0.0.1\MyTest1"
$Letter = "k"
####---------------####


Foreach($EachServer in $Computername){
    Write-Host "Working on $EachServer"
    if(Test-Connection -ComputerName $EachServer -Count 2 -Quiet)
    {
        try{

       
        Start-Process -Filepath $PSExec -ArgumentList "\\$EachServer -u $user_d -p $pswd_d net use N: $Drive" -Wait
        Start-Process -Filepath $PSExec -ArgumentList "\\$EachServer -u $user_d -p $pswd_d xcopy p:\ E:\GCTI\Software /E" -Wait
        #Start-Process -Filepath $PSExec -ArgumentList "\\$EachServer -u $user_d -p $pswd_d net use p: /delete" -Wait


        ##get foldersize after copy
        $dirSize = Get-ChildItem "\\$EachServer\E$\GCTI\Software" -recurse -force | select Length  |Measure-Object -Sum
        $dirSize.sum = $dirSize.sum/1MB

        $op = "Copied - $dirSize.sum"
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
