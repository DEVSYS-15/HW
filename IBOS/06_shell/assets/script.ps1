param(
    [string]$inputSTR
)
if ($args.Length -gt 1)
    {exit 1}

if ($inputSTR -eq 'crypt')
    {
        $out = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($args))
        Write-Host 'Encrypting...'
        Write-Host $out
    }
if ($inputSTR -eq 'decrypt' )
    {
        $out = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($args))
        Write-Host 'Decrypting...'
        Write-Host $out
    }
else {
    exit 1
}


