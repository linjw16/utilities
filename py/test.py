#! /usr/bin/env python3
import itertools
import logging
import random
import sys
import os

import scapy.utils
from scapy.layers.l2 import Ether
from scapy.layers.inet import IP, UDP


class TB(object):
	def __init__(self, debug=True):
		self.expected_output = []
		self.WIDTH = 6
		self.DEPTH = 4

		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("TB")
		self.log.setLevel(level)
			
			
	def model(self, din):
		"""Model of FracTCAM"""
		din_i = []
		out_1 = sys.maxsize % (1 << self.WIDTH)
		for i in range(self.WIDTH):
			din_i.append(din >> (i*self.DEPTH))
			out_1 = out_1 & din_i[i]
			self.log.debug("(out_1, din_i) = (%s,%s)" % (bin(out_1), bin(din_i[i])))
			print("(out_1, din_i) = (%s,%s)" % (bin(out_1), bin(din_i[i])))
		return out_1
		

def random_payload(times=1, length=8, min=0, max=0x100):
	max = 0x100 if max > 0x100 else max
	min = 0x0 if min < 0x0 else min
	set = range(min, max)
	for i in range(times):
		rand_set = random.sample(set, length)
		yield bytes(itertools.islice(itertools.cycle(rand_set), length))


def rand_payload(times=1, length=8):
	max = 0x100
	min = 0x0
	set = range(min, max)
	rand_set = random.shuffle(set)
	for i in range(times):
		yield itertools.islice(itertools.cycle(rand_set), length)


def random_payload_1(length=8, min=0, max=0x100):
	set = range(0, length)
	set = set % (max-min) + min
	rand_set = random.sample(set, length)
	return bytes(itertools.islice(itertools.cycle(rand_set), length))


def test_1 ():
	tb = TB()
	# for din in [random_payload(3, 0, 0x100) for i in range(4)]:
	for din in random_payload(4, 3, 0, 0x100):
		in_1 = int.from_bytes(din, byteorder='big')
		print("Input: %X = %s" % (in_1, bin(in_1)))
		out_1 = tb.model(in_1)
		print("Output: %X = %s" % (out_1, bin(out_1)))


def test_bytes():
	str_1 = "FFFF"
	bytes_1 = str_1.encode('utf-8')
	str_2 = bytes_1.decode('utf-8')
	print(bytes_1)
	print(str_2)
	int_1 = int.from_bytes(bytes_1, byteorder='big')
	int_2 = int.from_bytes(bytes_1, byteorder='big',signed=True)
	print(hex(int_1))
	print(hex(int_2))


def test_rand():
	bytes_1 = random_payload_1(length=280, min=0, max=0x100)
	len_1 = bytes_1.__len__()
	print(len_1)


def f_assign(data_in=0x10, data_set=0x1, offset=0x0, width=0x1, length=128):
	mask_1 = (((1 << width)-1) << offset) | (1<<length)
	# print("data_in \t= %x\nmask \t= %x" % (data_in, mask_1))
	data_in = data_in & (~mask_1)
	data_set = (data_set << offset) & mask_1
	data_out = data_in | data_set
	# print("data_set \t= %x\ndata_out \t= %x" % (data_set, data_out))
	return data_out


def f_act_code(port_id=0x1, fwd_en=True, vl_data=0x1, vl_op=0x0, cks_en=True, d_mac=0x01, d_mac_en=True, s_mac=0x01, s_mac_en=True):
	d_1 = 0
	d_1 = f_assign(d_1, port_id, 	118, 	4)
	d_1 = f_assign(d_1, fwd_en, 	117, 	1)
	d_1 = f_assign(d_1, vl_data, 	101, 	16)
	d_1 = f_assign(d_1, vl_op, 		99, 	2)
	d_1 = f_assign(d_1, cks_en, 	98, 	1)
	d_1 = f_assign(d_1, s_mac, 		50, 	48)
	d_1 = f_assign(d_1, s_mac_en, 	49, 	1)
	d_1 = f_assign(d_1, d_mac, 		1, 		48)
	d_1 = f_assign(d_1, d_mac_en, 	0, 		1)
	bin_1 = bin(d_1)
	len_1 = len(bin_1)-2
	f_act_print(d_1, 	118, 	4,  	"	port_id	")
	f_act_print(d_1, 	117, 	1, 		"	fwd_en	")
	f_act_print(d_1, 	101, 	16, 	"	vl_data	")
	f_act_print(d_1, 	99, 	2, 		"	vl_op	")
	f_act_print(d_1, 	98, 	1, 		"	cks_en	")
	f_act_print(d_1, 	50, 	48, 	"	s_mac	")
	f_act_print(d_1, 	1, 		48, 	"	d_mac	")

def f_act_print(action_code, offset=0, width=0, str_1=""):
	if (width==0):
		width = len(hex(action_code))-2
	mask = (1 << width)-1
	int_1 = (action_code >> offset) & mask
	print("%s: %#x" % (str_1, int_1))

def size_list():
	len_min = 8
	len_max = 8
	return list(range(len_min, len_max+1))


def incrementing_payload(length):
	return bytes(itertools.islice(itertools.cycle(range(1, 256)), length))


async def run_test(dut=None, payload_lengths=None, payload_data=None, config_coroutine=None, idle_inserter=None, backpressure_inserter=None):
	for payload in [payload_data(x) for x in payload_lengths()]:
		# 0xC0A80110 0xC0A880111
		eth = Ether(src='50:51:52:53:54:55', dst="D0:D1:D2:D3:D4:D5")
		d_ip_l = random.randint(0, 0x1F)
		d_ip = '192.168.1.'+str(d_ip_l)
		ip = IP(src='192.168.1.16', dst=d_ip)
		udp = UDP(sport=1, dport=2)
		pkt_sent = eth / ip / udp / payload
		print(type(pkt_sent))
		print((pkt_sent))
		print((pkt_sent.build()))
		# tb.dut.action_code.value =
		int_1 = f_act_code(vl_data=0xFFFF,
                                        vl_op=0b00,
                                        port_id=0x1,
                                        fwd_en=True,
                                        cks_en=True,
                                        d_mac=0xDAD1D2D3D4D5,
                                        d_mac_en=True,
                                        s_mac=0x5A5152535455,
                                        s_mac_en=True)
		try:
			assert 1
		except AssertionError:
			print("")


def run_coroutine():
	a = size_list
	b = incrementing_payload
	try:
		run_test(payload_lengths=a, payload_data=b).send(None)
	except StopIteration as e:
		print(e.value)


if(__name__=="__main__"):
	run_coroutine()
