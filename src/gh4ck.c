/**	Game Hackers Toolkit -- Hack your ipod touch games

	Author: kD3\/ <kd3v@live.ca>

	gh4ck.c -- generates a toolkit to allow users to hack their games

**/

#include <sys/types.h>
#include <stdlib.h>

int main( void ) {
	if ( (setuid(0)) == 0 ) {
		setuid(0); // double check
	} else {
		return -1;
	}

	system("/var/gh4ck/gh4ck.sh");
}
