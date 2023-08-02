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

# Get the starting date (today by default)
$startDate = Get-Date -Format "yyyy-MM-dd"

# Authenticate with Google Calendar API and get the access token
# Replace "YOUR_ACCESS_TOKEN" with your actual access token.

$EventsEndpoint = "calendars/$($calendarName)/events"
$QueryParameters = @{
    "calendarId"   = "primary"
    "orderBy"      = "startTime"
    "singleEvents" = "true"
    "q"            = "CT BC Tech Monthly"
    "timeMin"      = "$startDate" + "T00:00:00Z"
}

# Retrieve events from the calendar using GET request
$events = Invoke-GoogleCalendarApi -Endpoint $EventsEndpoint -AccessToken $accessToken -QueryParameters $QueryParameters

# Prepare the output data
foreach ($event in $events.items) {
    $eventSummary = $event.summary
    $eventStartTime = $event.start.dateTime

    Write-Host "Event Name: $eventSummary`n"
    Write-Host "Start Time: $eventStartTime`n"
}
if ($events.items.Count -gt 0) {
    Write-Host "Total events: $($events.items.Count)"
    Write-Host
    Write-Host "Confirm delete events? (y/n)"
    $confirm = Read-Host
    if ($confirm -ne "y") {
        Write-Host "Aborted."
        exit
    }
} else {
    Write-Host "No events found."
}

foreach ($event in $events.items) {
    $Endpoint = calendars/$($calendarName)/events/$($event.id)
    Invoke-GoogleCalendarApi -Endpoint $Endpoint -AccessToken $accessToken -Method Delete
    Write-Output "Deleted event with ID: $($event.id)"
}
