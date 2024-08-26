# Fireshare Right Click Context Menu Upload Video
This project allows uploading of gameplay videos to Fireshare (via SSH) by right clicking on some mp4 video files, it will generate a unique link that can be immediately shared with others.

At the moment, fireshare is only able to upload to specified folder `eg. public` and only possible via WebUI, the process is quite manual. In a typical gaming scenario, Shadowplay or OBS will be able to record many games via separate folders or the user is likely organizing their clips in a folder structure. Hence, users need to share multiple folders and game clips to fireshare, this project aims to simplify the process.

Fireshare Repo: https://github.com/shaneisrael/fireshare

## Demo
![Demo](demo.gif)

## Pre-requisites
- [Fireshare](https://github.com/shaneisrael/fireshare?tab=readme-ov-file#installation) setup and configured properly (allow all public access)
- Windows PC with Python and Powershell
    - xxhash: `pip install xxhash`
- SSH access to server hosting Fireshare and ability to modify files (public key authentication)
- Context Menu Manager (Optional): [Context Menu Manager](https://github.com/BluePointLilac/ContextMenuManager)

## Installation
1. Clone this repository
2. Install `xxhash` in Python or a virtual environment
3. Prepare `.env` file.

## Configuration
Content of `.env`
```
server=laptopserver
container=fireshare
python=venv/Scripts/python
remotedir=/mnt/nvme/share/gaming
url=https://fireshare.video.etc
```
- `server`: the username and hostname of the server running fireshare eg. `ubuntu@192.168.0.2` or `myubuntuserver` if [SSH config](https://stackoverflow.com/a/56536275) is setup
- `container`: the name of the Docker container running fireshare on the server, this is defined when your create your fireshare container in `docker-compose.yml`
- `python`: the path to the python executable in the virtual environment
- `remotedir`: the directory where the videos will be uploaded to on the remote server
- `url`: the url of the fireshare server (without the trailing `/`)

## Usage
The powershell script will upload the video to the server and generate a unique link that can be shared with others. The link will be copied to the clipboard. The script will get the folder name where the file is `eg. Game Name` and search the remote server for the folder, if it does not exist, it will prompt user to choose a folder to create, else if will upload the video to the folder.

The best practice is to name the folder on the remote server the same as your recording software's game name as this may not be easily changed.

## Context Menu
Create a .bat file to run the script in the same folder with the following content:
```bat
pushd %USERPROFILE%\fireshare-import :: change me
powershell -File fireshare.ps1 "%~1"
```
- `%~1` is important to pass the file path without spaces to the script
- change the path to the location of the script on your Windows PC

Make a command in Context Menu Manager with the following settings:
```bat
cmd /k pushd "%%USERPROFILE%%\fireshare-import" && fireshare.bat "%1"
```
- change `/k` to `/c` if you want the window to close after running the script; `/k` is useful for debugging
- double % is required to escape the environment variable

You can also use any third party software to add a context menu item to run the script.
Here is an example registry file to add a context menu item:
```reg
Windows Registry Editor Version 5.00    

[HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Item0]
"MUIVerb"="Fireshare"
"SubCommands"=""
"HasLUAShield"=""
"Icon"="imageres.dll,178"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Item0\shell]

[HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Item0\shell\Item0]
"MUIVerb"="Share"
"Icon"="C:\\Windows\\System32\\cmd.exe,0"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Item0\shell\Item0\command]
@="cmd /c pushd \"%%USERPROFILE%%\\fireshare-import\" && fireshare.bat \"%1\""
```
- change the path to the script in the registry file
- this will add a context menu item to all `.mp4` files only

**Disclaimer**: This project is not affilated with Fireshare, it is a personal project to simplify the process of uploading videos to Fireshare. Use at your own risk.