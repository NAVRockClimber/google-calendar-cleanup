function Get-AuthorizationCode {
    param (
        [string]$ClientId,
        [string]$RedirectUri
    )

    $response = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/device/code" -Body @{
        "client_id" = $clientId
        "scope"     = "https://www.googleapis.com/auth/calendar"
    }
    $deviceCode = $response.device_code
    $userCode = $response.user_code
    $verificationUrl = $response.verification_url
    Write-Host "Please visit $verificationUrl and enter code $userCode"
    Write-Host "Waiting for authorization... Press enter to continue."
    Read-Host | Out-Null
    return  $deviceCode
}
Export-ModuleMember -Function Get-AuthorizationCode

# Function to get the access token using the authorization code
function Get-AccessTokenFromAPI {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$DeviceCode
    )

    $response = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" -Body @{
        "client_id"     = $ClientId
        "client_secret" = $ClientSecret
        "code"          = $DeviceCode
        "grant_type"    = "http://oauth.net/grant_type/device/1.0"
    }
    $AccessTokenFile = Get-AccessTokenFileName
    $RefreshTokenFile = Get-RefreshTokenFileName
    Set-Content -Path $AccessTokenFile -Value $response.access_token -NoNewline
    Set-Content -Path $RefreshTokenFile -Value $response.refresh_token -NoNewline
    return $true
}
Export-ModuleMember -Function Get-AccessTokenFromAPI

function Test-TokenIsValid {
    param (
        [string]$AccessToken
    )

    try {
    $response = Invoke-RestMethod -Method Get -Uri "https://oauth2.googleapis.com/tokeninfo?access_token=$($AccessToken)"
    } catch {
        $response = $_.Exception.Response
        return $false
    }
    return $response.expires_in -gt 0
}
Export-ModuleMember -Function Test-TokenIsValid

function Get-NewTokenWithRefreshToken {
    param(
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$BaseFolder = $PSScriptRoot
    )
    $RefreshTokenFile = Get-RefreshTokenFileName -BaseFolder $BaseFolder
    $RefreshToken = Get-Content $RefreshTokenFile
    
    $body = @{
        "client_id" = $ClientId
        "client_secret" = $ClientSecret
        "refresh_token" = $RefreshToken
        "grant_type" = "refresh_token"
    }

    $response = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" -Body $body
    $accessToken = $response.access_token

    $AccessTokenFile = Get-AccessTokenFileName -BaseFolder $BaseFolder
    Set-Content -Path $AccessTokenFile -Value $accessToken -NoNewline

    return $accessToken
}
Export-ModuleMember -Function Get-NewTokenWithRefreshToken