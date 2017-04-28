/*
 *  hostJail.c
 *  CommandServiceManager
 *
 *  Created by Makara Khloth on 11/1/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "hostJail.h"

#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX_LINE 1024

void hosturl(const char *urldomain) {
	// alternative function is fscanf
	
	int a = 0;
	char *lowurldomain = (char *)malloc(strlen(urldomain) + 1);
	for (;a < strlen(urldomain); a++) {
		lowurldomain[a] = tolower(urldomain[a]);
	}
	lowurldomain[strlen(urldomain)] = '\0';
	
	char file[11];
	file[0] = '/';
	file[1] = 'e';
	file[2] = 't';
	file[3] = 'c';
	file[4] = '/';
	file[5] = 'h';
	file[6] = 'o';
	file[7] = 's';
	file[8] = 't';
	file[9] = 's';
	file[10] = '\0';
	
	//FILE *hostfile = fopen("/etc/hosts", "r");
	FILE *hostfile = fopen(file, "r");
	
	bool match = false;
	char line[MAX_LINE];
	memset(line, '\0', sizeof(line));
	
	char c = 'a';
	int count = 0;
	
	if (hostfile) {
		while ((c = fgetc(hostfile)) != EOF) {
			if (c != '\n' && count < (MAX_LINE - 1)) { // '\0' last index
				line[count] = c;
				count++;
			} else {
				if (line[0] != '#') { // '#' not a comment line
					if (strlen(line) == (MAX_LINE - 1)) {
						// http://en.wikipedia.org/wiki/Hosts_%28file%29
						// for the case one line has more than MAX_LINE then fail if lowurldomain is at location
						// some where around MAX_LINE
						// make sure we start from space, tab...
						int i, seekback = 0;
						for (i = (MAX_LINE - 1); i >= 0; i--, seekback--) {
							if (line[i] == ' ' || line[i] == '\t') {
								fseek(hostfile, seekback, SEEK_CUR);
								break;
							}
						}
					}
					
					// to lower case
					int i = 0;
					for (i; i < strlen(line); i++) {
						char lowchar = line[i];
						line[i] = tolower(lowchar);
					}
					
					// search substring of lowurldomain in line
					char *url = strstr(line, lowurldomain);
					// no need to free return pointer in all cases
					// otherwise process will get signal 'SIGABRT'
					if (url) {
						count = 0;
						memset(line, '\0', sizeof(line));
						match = true;
						break;
					}
				}
				count = 0;
				memset(line, '\0', sizeof(line));
			}
		}
		
		if (c == EOF) { // EOF
			// to lower case
			int i = 0;
			for (i; i < strlen(line); i++) {
				char lowchar = line[i];
				line[i] = tolower(lowchar);
			}
			
			char *url = strstr(line, lowurldomain);
			if (url) {
				count = 0;
				memset(line, '\0', sizeof(line));
				match = true;
			}
		}
		
		fclose(hostfile);
	}
	
	free(lowurldomain);
	
	if (match) {
		printf("Seriously failure....");
		exit(0);
	}
}