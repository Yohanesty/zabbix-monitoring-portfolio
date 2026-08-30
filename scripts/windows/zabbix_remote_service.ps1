param(
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,

    [ValidateSet('Start','Stop','Restart','Status')]
    [string]$Action = 'Status',

    [ValidateRange(1,300)]
    [int]$TimeoutSeconds = 30
)

$AllowedServices = @(
    'SampleService',
    'SampleBatchService'
)

if ($AllowedServices -notcontains $ServiceName) {
    Write-Output "DENIED: service is not in the allow-list: $ServiceName"
    exit 3
}

try {
    $svc = Get-Service -Name $ServiceName -ErrorAction Stop
} catch {
    Write-Output "ERROR: service not found: $ServiceName - $($_.Exception.Message)"
    exit 4
}

$timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)

try {
    switch ($Action) {
        'Start' {
            if ($svc.Status -eq 'Running') {
                Write-Output "ALREADY_RUNNING: $ServiceName"
                exit 0
            }
            Start-Service -Name $ServiceName -ErrorAction Stop
            $svc = Get-Service -Name $ServiceName -ErrorAction Stop
            $svc.WaitForStatus('Running', $timeout)
            Write-Output "SUCCESS: $ServiceName started"
            exit 0
        }
        'Stop' {
            if ($svc.Status -eq 'Stopped') {
                Write-Output "ALREADY_STOPPED: $ServiceName"
                exit 0
            }
            Stop-Service -Name $ServiceName -ErrorAction Stop
            $svc = Get-Service -Name $ServiceName -ErrorAction Stop
            $svc.WaitForStatus('Stopped', $timeout)
            Write-Output "SUCCESS: $ServiceName stopped"
            exit 0
        }
        'Restart' {
            Restart-Service -Name $ServiceName -ErrorAction Stop
            $svc = Get-Service -Name $ServiceName -ErrorAction Stop
            $svc.WaitForStatus('Running', $timeout)
            Write-Output "SUCCESS: $ServiceName restarted"
            exit 0
        }
        'Status' {
            $svc = Get-Service -Name $ServiceName -ErrorAction Stop
            Write-Output "$($svc.Status): $ServiceName"
            if ($svc.Status -eq 'Running') { exit 0 } else { exit 1 }
        }
    }
} catch [System.ServiceProcess.TimeoutException] {
    $timeoutMessage = $_.Exception.Message
    $current = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    $currentStatus = if ($current) { $current.Status } else { 'Unknown' }
    Write-Output "ERROR: timeout waiting for $Action on $ServiceName after ${TimeoutSeconds}s; CurrentStatus=$currentStatus - $timeoutMessage"
    exit 1
} catch {
    Write-Output "ERROR: $Action failed for $ServiceName - $($_.Exception.Message)"
    exit 1
}
