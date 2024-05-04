param(
    [string]$inputSTR
)
$count = 0
ForEach ($item in $inputSTR)
    {
    if ([System.IO.Directory]::Exists($item))
        {$items= $(Get-ChildItem $item | ForEach-Object { $_.Name})
        foreach ($files in $items){
            Write-Host $files
            if ([System.IO.File]::Exists($item+$files))
                {$count +=1 }
            }
        Write-Host 'Total:' $count
    }    
    if  (-not [System.IO.Directory]::Exists($item))
        {Write-Host $item '- not exist' -f Red}
}
