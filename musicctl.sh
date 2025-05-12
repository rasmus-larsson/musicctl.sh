
#!/bin/bash

cmd="$1"
arg="$2"

run_osascript() {
  osascript -e "tell application \"Music\" to $1"
}

print_help() {
  cat <<EOF
Usage: $(basename "$0") [command]

Commands:
  play                          Play music
  pause                         Pause music
  playpause                     Toggle play/pause
  stop                          Stop playback
  next                          Next track
  previous                      Previous track
  shuffle on|off                Enable or disable shuffle mode
  repeat off|one|all            Set repeat mode
  state                         Show current player state
  track                         Show current track name
  artist                        Show current track artist
  album                         Show current track's album
  playing                       Show current track in format: Artist - Song (Album)
  search                        Fuzzy search and play a track
  playlists                     Fuzzy pick and play a playlist
  help, h                       Show this help message
EOF
}

now_playing() {
  osascript <<'EOF'
tell application "Music"
  try
    if player state is playing then
      set trackName to name of current track
      set artistName to artist of current track
      set albumName to album of current track
      set trackNumber to track number of current track
      return "Playing: " & artistName & " - " & trackName & " [#" & trackNumber & " " & albumName & "]"
    else
      return "Music is not playing."
    end if
  on error
    return "No track info available."
  end try
end tell
EOF
}

fuzzy_search() {
  map=$(osascript <<'EOF'
tell application "Music"
  set output to ""
  repeat with t in (every track)
    if duration of t is not missing value then
          set trackName to name of t
          set artistName to artist of t
          set albumName to album of t
          set trackNumber to track number of t
          set display to trackName & " - " & artistName & " [#" & trackNumber & " " & albumName & "]"
          set encoded to trackName & "||" & artistName
          set output to output & display & tab & encoded & linefeed
      end if
  end repeat
  return output
end tell
EOF
)

  selected=$(echo "$map" | fzf --with-nth=1 --delimiter='\t' --query="$arg" | cut -f2)

  if [ -n "$selected" ]; then
    trackName="${selected%%||*}"
    artistName="${selected#*||}"

    trackName="${trackName//\"/\\\"}"
    artistName="${artistName//\"/\\\"}"

    osascript <<EOF
tell application "Music"
  try
    set theTrack to first track whose name is "$trackName" and artist is "$artistName"
    play theTrack
  on error
    display dialog "Track not found or unavailable."
  end try
end tell
EOF
    else
        echo "No track selected."
    fi

    now_playing
}


fuzzy_playlist() {
    playlist_name=$(osascript -e '
      tell application "Music"
        set playlistNames to name of every user playlist
        set textList to ""
        repeat with pl in playlistNames
          set textList to textList & pl & linefeed
        end repeat
        return textList
      end tell
    ' | fzf --prompt="Select Playlist: " --query="$arg")

    if [ -n "$playlist_name" ]; then
      osascript -e "tell application \"Music\" to play the playlist named \"$playlist_name\""
    else
      echo "No playlist selected."
    fi

    now_playing
}

case "$cmd" in
  search)
    fuzzy_search
    ;;
  stop)
    run_osascript "stop"
    ;;
  play)
    run_osascript "playpause"
    ;;
  play)
    run_osascript "play"
    ;;
  pause)
    run_osascript "pause"
    ;;
  next)
    run_osascript "next track"
    ;;
  previous)
    run_osascript "previous track"
    ;;
  state)
    run_osascript "player state"
    ;;
  track)
    run_osascript "name of current track"
    ;;
  artist)
    run_osascript "artist of current track"
    ;;
  album)
    run_osascript "album of current track"
    ;;
  playlists)
    fuzzy_playlist
    ;;
  playing)
    now_playing
    ;;
  shuffle)
    case "$arg" in
      on)  run_osascript "set shuffle enabled to true" ;;
      off) run_osascript "set shuffle enabled to false" ;;
      *)   echo "Usage: $(basename "$0") shuffle {on|off}"; exit 1 ;;
    esac
    ;;
  repeat)
    case "$arg" in
      off|none) run_osascript "set song repeat to off" ;;
      one)      run_osascript "set song repeat to one" ;;
      all)      run_osascript "set song repeat to all" ;;
      *)        echo "Usage: $(basename "$0") repeat {off|one|all}"; exit 1 ;;
    esac
    ;;
  help|h|*)
    print_help
    ;;
esac
