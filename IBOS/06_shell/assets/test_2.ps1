param(
    [string]$inputINT
)

Try { 
    [convert]::ToInt32($inputINT) 
    [int]$inputINT+=1
    Write-Host $inputINT 
    } 
    Catch { 
    Write-Host  $inputINT 'is not INT'
    } 
