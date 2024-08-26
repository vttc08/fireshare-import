Add-Type -AssemblyName System.Windows.Forms # needed to MsgBox
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

get-content .env | ForEach-Object {
    $name, $value = $_.split('=')
    set-content env:\$name $value
}

$server = $env:server
$container = $env:container
$python = $env:python
$remotedir=$env:remotedir
$url = $env:url

function ssh_command {
    param ( $command )
    ssh $server "$command"
}

$dirs = $(ssh $server "ls $remotedir") # check remote directories
$dir = (get-item $args[0]).directory.Name # get directory name eg. Overwatch
$basename = (get-item $args[0]).Name # file name eg. video.mp4

if ($dirs -contains $dir) { 
    # if remote directory exists upload there
    $dest = "$remotedir/$dir"
}
else { 
    # if not, make one and upload there
    $option = Read-Host "Directory does not exist. Enter a name to make one or use existing. Existing options are:`n$dirs"
    $command = "mkdir -p '$remotedir/$option'"
    ssh_command $command
    $dest = "$remotedir/$option/$basename"
}

$vid = $(& $python vid.py $args[0]) # python script to get video hash url
$sharelink = "$url/w/$vid" # full fireshare URL

# Copy the file over to the server
$realdest = "'$dest'"
scp $args[0] $server`:$realdest

# Force scan fireshare
$refresh = "docker exec $container fireshare bulk-import"
ssh_command "$refresh"

# Finalize
Set-Clipboard $sharelink
[System.Windows.MessageBox]::Show($sharelink, "Link copied to clipboard", "OK", "Information")