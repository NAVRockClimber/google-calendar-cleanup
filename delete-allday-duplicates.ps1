$ModulesPath = Join-Path -Path $PSScriptRoot -ChildPath "modules"
$GoogleAuthPath = Join-Path -Path $ModulesPath -ChildPath "navrockclimber.google.auth"
$GoogleCalendarPath = Join-Path -Path $ModulesPath -ChildPath "navrockclimber.google.calendar"
$GoogleAuthModulePath = Join-Path -Path $GoogleAuthPath -ChildPath "navrockclimber.google.auth.psd1"
$GoogleCalendarModulePath = Join-Path -Path $GoogleCalendarPath -ChildPath "navrockclimber.google.calendar.psd1"
Import-Module $GoogleAuthModulePath -Force
Import-Module $GoogleCalendarModulePath -Force

$accessToken = Get-AccessToken -BaseFolder $PSScriptRoot

# Specify the calendar name (change this to your calendar name)
$calendarName = "primary"

$startDate = Get-Date -Format "yyyy-MM-dd"
$endDate = Get-Date -Month 12 -Day 31 -Format "yyyy-MM-dd"
$EventsEndpoint = "calendars/$($calendarName)/events"
$QueryParameters = @{
    "timeMin" = "$($startDate)T00:00:00Z"
    "timeMax" = "$($endDate)T00:00:00Z"
    "singleEvents" = $true
    "orderBy" = "startTime"
    "maxResults" = 2500
    #"q" = "Mariä Himmelfahrt"
}
$response = Invoke-GoogleCalendarApi -Endpoint $EventsEndpoint -AccessToken $accessToken -QueryParameters $QueryParameters
$responseItems = $response.Content | ConvertFrom-Json -Depth 10
$events = $responseitems.items | Where-Object { $_.start.date -ne $null } # all-day events have start.date instead of start.dateTime
$duplicates = $events | Group-Object -Property { $_.start.date } | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Group
$previousName = ""
foreach ($duplicate in $duplicates) {
    if ($duplicate.summary -ne $previousName) {
        $previousName = $duplicate.summary
        continue
    }
    $Endpoint = "calendars/$($calendarName)/events/$($duplicate.id)"
    Invoke-GoogleCalendarApi -Endpoint $Endpoint -AccessToken $accessToken -Method Delete | Out-Null
    Write-Output "Deleted event with ID: $($duplicate.id)"
}
