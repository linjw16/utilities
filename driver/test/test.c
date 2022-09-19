/*
 * Created on Tue Jul 19 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 test.c
 * @Author:		 Jiawei Lin
 * @Last edit:	 14:42:43
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#define MOD_NAME "linjw"

//设置初始化入口函数
static int __init hello_init(void)
{
	printk(KERN_EMERG MOD_NAME ":\thello world!!!\n");
	return 0;
}

//设置出口函数
static void __exit hello_exit(void)
{
	printk(KERN_EMERG MOD_NAME ":\tgoodbye world!!!\n");
}

//将上述定义的init()和exit()函数定义为模块入口/出口函数
module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("linjw");