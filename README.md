# itunes-to-agptek

A script to export iTunes playlists to AGPTEK A65 or Ruizu mp3 players. You have to make sure the playlist is downloaded to the local directory.
The you can export the playlist into XML files and use this script like:

`./export_playlist.sh Playlist Name.xml Playlist_Name`

This will create a directory like `MUSIC/Playlist_Name` in which all the M4A files are copied in the same order as they are in the playlist, and with safe names.
It will also create a file like `Playlist_Name.m3u` which describes the playlist. 

You can copy all that to the device (e.g. with `cp -R *.m3u MUSIC /Volumes/AGP-A65`) and the playlists should be recognized.