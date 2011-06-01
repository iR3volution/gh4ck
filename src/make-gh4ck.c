/**	Game Hackers Toolkit -- Hack your ipod touch games

	Author: kD3\/ <kd3v@live.ca>


	make-gh4ck.c -- packages hacks made with gh4ck

**/

#include <sys/types.h>
#include <stdlib.h>

int main( void ) {
	if ( (setuid(0)) == 0 ) {
		setuid(0); // double check
	} else {
		return -1;
	}

	system("/var/gh4ck/make-gh4ck.sh");
}
