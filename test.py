#! /usr/bin/env python3
import itertools
import logging
import random
import os

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
		out_1 = 0xFFFF
		for i in range(self.WIDTH):
			din_i.append(din >> (i*self.DEPTH))
			out_1 = out_1 & din_i[i]
		return out_1
		

def random_payload(length=8, min=0, max=0x100):
	set = range(min, max)
	rand_set = random.sample(set, length)
	rand_set = [0xFF, 0xFF, 0xFF, rand_set]
	return bytes(itertools.islice(itertools.cycle(rand_set), length))
	


if(__name__=="__main__"):
	tb = TB()
	for din in [random_payload(3,0,0x100) for i in range(4)]:
		in_1 = int.from_bytes(din, byteorder='big')
		print("Input: %X = %s" % (in_1, bin(in_1)))
		out_1 = tb.model(in_1)
		print("Output: %X = %s" % (out_1, bin(out_1)))
