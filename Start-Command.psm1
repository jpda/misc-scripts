function Start-CommandWithVars {
    param (
        [Parameter(Position = 0)]
        [ScriptBlock]$CommandBlock = { Get-ChildItem Env:  },
        [string]$EnvFilePath =  $(Get-ChildItem -Path $PWD -Filter *.vscode.env -Recurse)
    )

    Write-Host Reading vars from $EnvFilePath

    $envVars = Get-Content $EnvFilePath | ForEach-Object {
        $line = $_.Trim()
        if (-not $line.StartsWith('#') -and $line -match '^(.*?)=(.*)$') {
            $key = $matches[1]
            $value = $matches[2]
            @{ $key = $value }
        }
    } | Where-Object { $_ }

    $envVarsHashTable = @{}
    $envVars | ForEach-Object {
        $k = $_.Keys | Select-Object -First 1
        $envVarsHashTable[$k] = $_[$k]
    }

    & {
        foreach ($key in $envVarsHashTable.Keys) {
            $value = $envVarsHashTable[$key]
            Set-Item -Path "Env:$key" -Value $value.Trim('"')
        }
        & $CommandBlock
}
}