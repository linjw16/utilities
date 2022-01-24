#! /usr/bin/env python3
import itertools
import logging
import random
import sys
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


if(__name__=="__main__"):
	tb = TB()
	# for din in [random_payload(3, 0, 0x100) for i in range(4)]:
	for din in random_payload(4, 3, 0, 0x100):
		in_1 = int.from_bytes(din, byteorder='big')
		print("Input: %X = %s" % (in_1, bin(in_1)))
		out_1 = tb.model(in_1)
		print("Output: %X = %s" % (out_1, bin(out_1)))
