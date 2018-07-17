function Watch-PeopleImportFromFile {
    param (
        $ComputerName='tdsb'
    )
    Watch-Process 'PeopleImportFromFile' $ComputerName
}

function Watch-TDBridge {
    param (
        $ComputerName="cron"
        ,$TaskName="*dynamix*bridge"
    )
    Watch-Task -ComputerName $ComputerName -TaskName $TaskName
}

function Watch-TDBridgeDev {
    param (
        $ComputerName="cron"
        ,$TaskName="*dynamix*dev"
    )
    Watch-Task -ComputerName $ComputerName -TaskName $TaskName
}
function Get-PeopleImportFromFileProcess {
    param (
        $ComputerName="tdsb"
    )
    Get-RunningProcess "PeopleImportFromFile" $ComputerName 
}