
This repo contains scripts for Chinese mud game - Xiyouji 2000 (A journey to the west). 
The mudding tool used is Tintin++.

To install tintin++ on mac:
1. download the tt++ source code from http://tintin.sourceforge.net/download.php
2. install pcre through homebrew
3. unzip the source code, go to /src, run `$ ./cofigure;make;make install`

Add a `characters` file in the main directory that contains list of user id and passwords, in the following format:
```
#var users {
	{user1} {pwd1}
	{user2} {pwd2}
}
```

Add alias in `~/.bash_profile`:
```
alias xyj='cd ~/directory_to_the_repo;tt++ xyj.tin'
```

To initiate connection to xyj, run:
`$ xyj`
