faedupes
========

Got thousands of files in various folders that probably have a bunch of
duplicates and you have been meaning to go through them but never got around to
it?  This tool might be able to help...

Obvious Disclaimer: duplicate file detected is an imperfect process and can go
wrong in various unexpected ways.  Excise appropriate caution.

Hazards include but are not limited to:

* Bind mounts, hard-links or other ways to making a file appear in more than one place in the file system.
* Sym-links - faedupes attempts to ignore these but you should still verify.
* File changes while scanning for duplicates.
* Multiple duplicate scanning tools running at the same time.
* Hash collisions - by default faedupes compares full file content.

faedupes should prefer caution and tend towards not detecting duplicates (false
negatives) instead of reporting erroneous duplicates (false positives).

Expected Usage
--------------

* In each of the directories that you are organising files into, run:

```shell
cd /mnt/bigdisk/photos
faedupes --reference
```

* Then in each folder of stuff you want to sort out, run:

```shell
cd /mnt/bigdisk/backups/old-laptop/old-old-laptop/Downloads
faedupes
```

faedupes will print a list of all the file in the working directory that are
duplicated somewhere else it has been shown previously.  There is nothing
special about a directory added via `--reference`, its a simple optimisation to
only record the files for later reference.

New files are only discovered from the current working directory.  `faedupes
--reference` needs to be re-run when files are added.

* If you want the dupes list much quicker, you can skip the byte-for-byte check
and dupes will be detected only by matching sha1 hashes:

```shell
faedupes --quick
```

* If you want to delete duplicates, faedupes can write you a shell script to review and run:

```shell
faedupes --write-script ./delete-dupes.sh
```

The script will contain one file per line to make it easy to grep/filter/etc.

How It Works
------------

faedupes will cross-reference all the files in the working directory with all
the files it has ever been shown and then list files in the working directory
that are also somewhere outside the working directory.

The basic approach:

* Find all files that are the same file size as a file in the working directory.
* Hash these files with matching sizes with sha1.
* For each possible duplicate, do a byte-for-byte comparison.
* Print the list of dupes along with the path to a duplicate of it (only the first dupe is shown even if there are others).

The list of files is stored in a sqlite databases at
`$HOME/.config/faedupes/db`, which also caches the hashes for faster reruns.
