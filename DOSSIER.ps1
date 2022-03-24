#Для работы скрипта необходимо установить модуль "Posh-SSH" коммандой Install-Module -Name Posh-SSH

Import-Module Posh-SSH

$DosiePath = "M:\example\example\"
$localPath = "C:\example\"

while($true){

    Write-Host("$(Get-Date)    Открываю сессию к Unix")
    $User = "example"
    $PWord = ConvertTo-SecureString -String "example" -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
    New-SFTPSession -ComputerName Unix -Credential ($Credential) -Verbose | fl
    Get-SFTPSession -SessionId 0

    if(Test-SFTPPath -Path /home/example/example/example/example/example/example/example -SessionId 0){

        $files = Get-SFTPChildItem -SessionId 0 -Path /home/example/example/example/example/example/example/example
    
        foreach($file in $files){
    
            if($file.FullName -like "*.zip"){

                Write-Host("$(Get-Date)    Копирование файлов")
        
                Get-SFTPFile -LocalPath $localPath -RemoteFile $file.FullName -SessionId 0 -Overwrite
                Remove-SFTPItem -Path $file.FullName -SessionId 0 -Force
        
            }

        }

    }

    Write-Host("$(Get-Date)    Закрываю сессию к Unix")

    Remove-SFTPSession -SessionId 0

    $localFiles = Get-ChildItem $localPath -File
    foreach($localFile in $localFiles){

        $SplitLocalFileName = $LocalFile.Name.Split("_.")
        $INN = $SplitLocalFileName[0]
        $BGNumber = $SplitLocalFileName[1]
        $BGPath = $DosiePath + $INN + "\" + $BGNumber
        Write-Host("$(Get-Date)    Создание папки $BGPath")
        New-Item -ItemType "directory" -Path $BGPath -Force
        $arcName = $localFile.Name
        Write-Host("$(Get-Date)    Распаковка архива $arcName")
        Expand-Archive -LiteralPath $localFile.FullName -DestinationPath $BGPath -Force
        Remove-Item $LocalFile.FullName
    }

    [System.GC]::Collect()
    Write-Host("$(Get-Date)    Пауза 30 минут")
    Start-Sleep 1800
}