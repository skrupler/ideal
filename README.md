# ideal.sh
A bash wrapper script for checking a directory of sub dirs with sfv files and files in them and move those directories who are incorrect into another directory (default: ./broken). 

## About
This ia a POSIX compliant wrapper script in bash which checks folders for sfv and then scans them. Those
who fail will be logged to a file (default: failed.log). Ideal is swedish and is a word something near
perfection which you want your releases to be. It makes use of cksfv for the actual sfv calculations.

### Dependencies

* bc
* cksfv

### Usage

`$ ideal.sh /path/to/directory`

### Example output
```bash
$~ ./ideal.sh /mnt/music/pop/2003
[▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒                                                       ]
Operation completed 40 scans.
5 broken releases.
35 intact releases.
```

### TODOs

* [] fix bug where dirs with spaces bor
* [x] write a failed rls log
* [] proper args handling
* [/] scrolling output yet with progressbar working(?)
* [] eliminate bc, awk perhaps?
* [] show percentage completion in margin #progressbar
* [] add maxdepth param via cmdline
