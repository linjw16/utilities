/*
 * Created on Wed Mar 16 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 hello_dev.c
 * @Author:		 Jiawei Lin
 * @Last edit:	 19:18:34
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/delay.h>
#define MOD_MAJOR 123
#define MOD_MINOR 456
#define MOD_NAME "mymod"

static int hello_open(struct inode *inode, struct file *file){
	printk(KERN_EMERG MOD_NAME "\t linjw: hello_open\n");
	return 0;
}

static ssize_t hello_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos){
	printk(KERN_EMERG MOD_NAME "\t linjw: hello_write\n");
	return 0;
}

/*
 * Instantiation of "file_operations", "__init", "__exit"
 */
static struct file_operations hello_flops = {
	.owner = THIS_MODULE,
	.open = hello_open,
	.write = hello_write,
	// .release = mqnic_release,
	// .mmap = mqnic_mmap,
	// .unlocked_ioctl = mqnic_ioctl,
};

static int __init hello_init(void){
	int rtn;
	rtn = register_chrdev(MOD_MAJOR, MOD_NAME, &hello_flops);
	if (rtn < 0){
		printk(KERN_EMERG MOD_NAME "\t can't register major number.\n");
		return rtn;
	}
	printk(KERN_EMERG MOD_NAME "\tlinjw: hello_init.\n");
	return 0;
}

static void __exit hello_exit(void){
	unregister_chrdev(MOD_MAJOR, MOD_NAME);
	printk(KERN_EMERG MOD_NAME "\tlinjw: hello_exit.\n");
}

module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("linjw");