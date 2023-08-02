function Invoke-GoogleCalendarApi {
    param (
        [string]$Endpoint,
        [string]$AccessToken,
        [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE")]
        [string]$Method = "GET",
        [hashtable]$QueryParameters = @{}
    )
    $baseUrl = "https://www.googleapis.com/calendar/v3"

    $queryParams = ($QueryParameters.GetEnumerator() | ForEach-Object {
            $_.Key + "=" + $_.Value
        }) -join "&"

    if ($queryParams.Length -gt 0 -and $null -ne $queryParams) {
        $url = "$($baseUrl)/$($Endpoint)?$($queryParams)" 
    } else {
        $url = "$($baseUrl)/$($Endpoint)"
    }
    return Invoke-WebRequest -Method $Method -Uri $url -Headers @{ "Authorization" = "Bearer $AccessToken" }
}
Export-ModuleMember -Function Invoke-GoogleCalendarApi