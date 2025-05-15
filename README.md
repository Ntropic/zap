# zap  ⚡

A blazing-fast, minimal command-line bookmarking system for your directories.
Forget long paths — jump around your filesystem with keyword shortcuts!



## Features

* `zap add <keyword> <path>` — bookmark a directory
* `zap add <keyword> .` — bookmark the current directory
* `zap rm <keyword>` — remove a bookmark
* `zap ls` — list all saved bookmarks
* `cd <keyword>` — smart `cd` that expands bookmark keywords
* Tab completion for bookmark names


## Installation

1. **Clone or copy** this repository or the `zap.sh` file
2. Add this to your `~/.bashrc` file:

```bash
source /path/to/zap.sh
```


## Example Usage

```bash
zap add proj /home/user/Documents/Projects
zap rm proj                # removes the bookmark
zap add proj .             # bookmarks current directory
zap ls

cd proj                    # jumps to bookmarked path
cd proj data/raw           # navigates into subfolder
```

## Tab Completion

Bookmark names are auto-completed when you use `cd`.

Example:

```bash
cd [TAB]         # shows proj, phd, etc.
```

Bookmarks are stored in an auto created file:

```
~/.cd_keywords.sh
```
## Author
Michael Schilling