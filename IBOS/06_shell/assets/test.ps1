param(
    [string]$inputSTR
)

ForEach ($item in $inputSTR)
    {

    if ([System.IO.Directory]::Exists($item))
        {Write-Host $item '- dir' -f Green
        
    if ([System.IO.File]::Exists($item))
        {Write-Host $item '- file' -f Green}
    }
    else 
        {Write-Host $item '- not exist' -f Red}
}
