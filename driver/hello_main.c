/*
 * Created on Wed Mar 16 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 hello_main.c
 * @Author:		 Jiawei Lin
 * @Last edit:	 19:18:02
 */

#include <fcntl.h>
#include <stdio.h>

int main(void) {
	int fd;
	int val = 1;
	fd = open("/dev/mydev", O_RDWR);
	if (fd < 0) {
		printf("can't open!\n");
	}
	// write(fd, &val, 4);
	return 0;
}