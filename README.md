# musicctl.sh

A simple command-line interface (CLI) for controlling Apple Music on macOS using Bash and AppleScript.

Control playback, search and play tracks, and more — all from your terminal.

---

## Features

- Play, pause, skip, and stop playback
- Fuzzy search and play tracks (using `fzf`)
- Show "now playing" track info
- Browse and play user playlists
- Toggle shuffle and repeat modes
- Simple, scriptable, and easy to integrate

---

## Installation

1. Clone the repository:

```sh
git clone https://github.com/rasmus-larsson/musicctl.sh.git
cd musicctl.sh
chmod +x musicctl.sh
```

--- 

## Dependencies

- macOS with the Music app
- fzf (for fuzzy search)

```sh
brew install fzf
```

---

## Usage

```sh
./musicctl.sh help
```

```
Usage: ./musicctl.sh [command]

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
  nowplaying                    Show current track in format: Artist - Song (Album)
  search                        Fuzzy search and play a track
  playlists                     Fuzzy pick and play a playlist
  help, h                       Show this help message
```
