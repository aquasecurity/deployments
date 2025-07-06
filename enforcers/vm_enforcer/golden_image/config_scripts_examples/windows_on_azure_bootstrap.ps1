param(
  [Parameter(Mandatory=$true)][string]$KvName,
  [Parameter(Mandatory=$true)][string]$ServerSecret,
  [Parameter(Mandatory=$true)][string]$TokenSecret
)

$ErrorActionPreference = 'Stop'

$configDir = 'C:\Program Files\AquaSec'
$tmpFile   = Join-Path $configDir '.config.tmp'
$finalFile = Join-Path $configDir 'GI_AQUA_CONFIG-prod_env.json'

# 1 ▪ get IMDS token
$imdsUrl   = 'http://169.254.169.254/metadata/identity/oauth2/token' +
             '?api-version=2019-08-01&resource=https://vault.azure.net'
$imdsToken = (Invoke-RestMethod -Headers @{Metadata='true'} -Uri $imdsUrl).access_token

# 2 ▪ fetch secrets
$base = "https://$KvName.vault.azure.net/secrets"
$api  = '?api-version=7.3'

$aquaServer = (Invoke-RestMethod -Headers @{Authorization = "Bearer $imdsToken"} `
                                 -Uri ("$base/${ServerSecret}$api")).value
$aquaToken  = (Invoke-RestMethod -Headers @{Authorization = "Bearer $imdsToken"} `
                                 -Uri ("$base/${TokenSecret}$api")).value

# 3 ▪ write JSON atomically
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
@{AQUA_SERVER = $aquaServer; AQUA_TOKEN = $aquaToken} `
  | ConvertTo-Json -Depth 2 `
  | Set-Content -Encoding ASCII -Path $tmpFile

icacls $tmpFile /inheritance:d /grant:r "SYSTEM:F" "BUILTIN\Administrators:F" | Out-Null
Move-Item -Force $tmpFile $finalFile
