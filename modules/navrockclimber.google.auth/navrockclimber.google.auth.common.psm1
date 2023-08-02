function Get-AccessTokenFileName {
    param(
        [string]$BaseFolder = $PSScriptRoot
    )
    $AccessTokenFile = Join-Path -Path $BaseFolder -ChildPath "access_token"
    return $AccessTokenFile
}
Export-ModuleMember -Function Get-AccessTokenFileName

function Get-RefreshTokenFileName {
    param(
        [string]$BaseFolder = $PSScriptRoot
    )    
    $RefreshTokenFile = Join-Path -Path $BaseFolder -ChildPath "refresh_token"
    return $RefreshTokenFile
}
Export-ModuleMember -Function Get-RefreshTokenFileName

function Get-SecretsFileName {
    param(
        [string]$BaseFolder = $PSScriptRoot
    )    
    $SecretsFile = Join-Path -Path $BaseFolder -ChildPath "client_secret.json"
    return $SecretsFile
}

function Get-AccessToken {
    param(
        [string]$BaseFolder = $PSScriptRoot
    )
    $clientSecretFile = Get-SecretsFileName -BaseFolder $BaseFolder
    $secrets_file = Get-Content $clientSecretFile | ConvertFrom-Json

    $authenticated = $false
    $AccessTokenFile = Get-AccessTokenFileName -BaseFolder $BaseFolder

    if (Test-Path $AccessTokenFile) {
        $accessToken = Get-Content $AccessTokenFile
        $authenticated = Test-TokenIsValid -AccessToken $accessToken
        if ($authenticated -eq $false) {
            $accessToken = Get-NewTokenWithRefreshToken -ClientId $secrets_file.installed.client_id -ClientSecret $secrets_file.installed.client_secret -BaseFolder $BaseFolder
            $authenticated = Test-TokenIsValid -AccessToken $accessToken
        }
    }

    if (-not $authenticated) {
        $authCode = Get-AuthorizationCode -ClientId $secrets_file.installed.client_id
        $authenticated = Get-AccessTokenFromAPI -ClientId $secrets_file.installed.client_id -ClientSecret $secrets_file.installed.client_secret -DeviceCode $authCode
    }
    $accessToken = Get-Content $AccessTokenFile
    return $accessToken
}
Export-ModuleMember -Function Get-AccessToken