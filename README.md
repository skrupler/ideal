# ideal.sh
A wrapper written in bash for checking a directory tree of sub directories containing `.sfv` files and then calculate the checksum and blacklist those whom are deemed unfit. 

## About
Ideal is a swedish word for something if not perfection, near perfection. This is a wrapper script in bash which checks folders for sfv files and then calculates them. Those
who fail will be logged to a file (default: `failed.log`). Ideal is swedish and is a word something near
perfection - which you want your releases to be. 
### Dependencies

* cksfv

### Usage
The default usage `./ideal.sh -t /path/to/target/ -r (music|movie)` does not touch anything except writing a `failed.log` to `~/` once `cksfv` is done calculating the checksums. The `failed.log` will be zeroed upon each new scan (read script invocation).

`$ ideal.sh -t /path/to/directory -w -m`

```bash

	ideal.sh -t /path/to/target -w -m /tmp

	-w			DANGER: Use with caution. Enables (w)rite mode. Use with --move. 
	-m			Directory to (m)ove broken releases into. Ignored unless -w is supplied.
				If no argument passed then directory ~/broken is assumed for moving the broken folders to.
	-t			(t)arget path to scan.
	-v			Toggles (v)erbose output. Prints successful sfv checks aswell.
	-d			Defines folder (d)epth from target path. ie -d 2 /path/to/podcast will search 2 levels down.
	-r			(r)elease type ie: music or movie.

	-h			Prints this (h)elp message.

```

### Example output
```bash
$ ideal.sh -t /mnt/music/pop/2003
[##################################################                                                      ]
Operation completed 40 scans.
5 broken releases.
35 intact releases.
```

### TODOs

- [ ] show percentage completion in margin #progressbar
- [ ] add maxdepth param via cmdline
- [ ] add archive possibility - aka save an archival log file aswell.
- [ ] cleanup stats which is printed after a scan
- [ ] colored output
- [ ] cleanup printf
- [x] fix bug where dirs with spaces bor
- [x] write a failed rls log
- [x] proper args handling
- [x] scrolling output yet with progressbar working(?)
- [x] eliminate bc, awk perhaps?
