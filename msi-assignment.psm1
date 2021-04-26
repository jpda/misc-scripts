
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][string]$Resource = "https://graph.microsoft.com/",
    [Parameter(Mandatory = $false)][string]$KeyPath = "C:\ProgramData\AzureConnectedMachineAgent\Tokens\*.key",
    [Parameter(Mandatory = $false)][switch]$IncludeFullResponse
)

function Get-ArcToken() {
    param(
        [Parameter(Mandatory = $false)][string]$Resource = "https://graph.microsoft.com/",
        [Parameter(Mandatory = $false)][string]$KeyPath = "C:\ProgramData\AzureConnectedMachineAgent\Tokens\*.key",
        [Parameter(Mandatory = $false)][switch]$IncludeFullResponse,
        [Parameter(Mandatory = $false)][switch]$Retry
    )
    $url = $ENV:IDENTITY_ENDPOINT + "?api-version=2020-06-01&resource=$resource";
    $key = "";
    
    Write-Verbose "Endpoint: $url"
    if (Test-Path -Path $KeyPath) {
        $key = $(Get-Content $KeyPath);
    }
    try {
        $resp = Invoke-WebRequest -Uri $url -Headers @{ Authorization = 'Basic ' + $key; Metadata = 'True' } -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        if ($IncludeFullResponse) {
            return $resp
            
        } return $data.access_token
        
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ = 401) {
            Get-ArcToken -Resource $Resource -KeyPath $KeyPath -Retry -IncludeFullResponse:$IncludeFullResponse
        }
    }
}

Export-ModuleMember -Function Get-ArcToken