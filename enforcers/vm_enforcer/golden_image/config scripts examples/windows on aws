<powershell>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol  = [Net.SecurityProtocolType]::Tls12

$ServerSecret = '<AQUA_SERVER_SECRET_NAME>'
$TokenSecret  = '<AQUA_TOKEN_SECRET_NAME>'

$imdsToken = Invoke-RestMethod -Method Put `
    -Uri     'http://169.254.169.254/latest/api/token' `
    -Headers @{ 'X-aws-ec2-metadata-token-ttl-seconds' = '60' }

$region = Invoke-RestMethod `
    -Uri     'http://169.254.169.254/latest/meta-data/placement/region' `
    -Headers @{ 'X-aws-ec2-metadata-token' = $imdsToken }

if (-not (Get-Command Get-SECSecretValue -ErrorAction SilentlyContinue)) {
    Install-Module -Name AWS.Tools.SecretsManager -Force -Scope AllUsers
}

function Get-PlainSecretValue {
    param (
        [Parameter(Mandatory)][string]$SecretId,
        [Parameter(Mandatory)][string]$Key
    )
    $json = (Get-SECSecretValue -SecretId $SecretId -Region $region).SecretString
    return ( $json | ConvertFrom-Json ).$Key
}

$AQUA_SERVER = Get-PlainSecretValue $ServerSecret 'AQUA_SERVER'
$AQUA_TOKEN  = Get-PlainSecretValue $TokenSecret  'AQUA_TOKEN'

$jsonConfig = @{ AQUA_SERVER = $AQUA_SERVER; AQUA_TOKEN = $AQUA_TOKEN } |
              ConvertTo-Json -Depth 2

$configPath = 'C:\Program Files\AquaSec\GI_AQUA_CONFIG-prod_env.json'
$tempPath   = "$configPath.tmp"

$jsonConfig | Set-Content -Path $tempPath -Encoding ASCII -Force

icacls $tempPath /inheritance:d `
                /grant:r "SYSTEM:F" "BUILTIN\Administrators:F" | Out-Null

Move-Item    -Path $tempPath -Destination $configPath -Force

</powershell>
