# Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
$OnViModeChange = [scriptblock]{
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    }
    else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

if ($host.Name -eq 'ConsoleHost')
{
    Import-Module -Name CompletionPredictor
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    # Set-PSReadLineOption -PredictionViewStyle ListView

    oh-my-posh --init --shell pwsh --config C:\Users\cneverov\.oh-my-posh\kipr.omp.json | Invoke-Expression
}

$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

function delete-all-branches { git branch -D $(git branch).Trim() }

function who-uses ($port) {
	Get-NetTCPConnection | where Localport -eq $port | select Localport,OwningProcess
}
