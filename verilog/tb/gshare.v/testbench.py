#
# Created on Tue Jul 26 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	 testbench.py
# @Author:		 Jiawei Lin
# @Last edit:	 18:11:23
#

import itertools
import logging
import random
import sys
import os

import warnings
# warnings.filterwarnings("ignore")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess
from cocotb_bus.drivers import BitDriver


class TB(object):
	def __init__(self, dut, debug=True):
		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("TB")
		self.log.setLevel(level)

		self.dut = dut
		self.DUMMY = self.dut.DUMMY.value
		self.log.debug("DUMMY = %d" % self.DUMMY)

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	async def reset(self):
		self.dut.predict_valid.value = 1
		self.dut.predict_pc.value = 4
		self.dut.train_valid.value = 1
		self.dut.train_taken.value = 1
		self.dut.train_mispredicted.value = 1
		self.dut.train_history.value = 0x7F
		self.dut.train_pc.value = 4
		self.log.info("Reset begin...")
		self.dut.areset.setimmediatevalue(0)
		for _ in range(4):
			await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.areset <= 1
		self.dut.predict_pc.value = 0xA
		self.dut.train_valid.value = 0
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.areset.value = 0
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.log.info("reset end")


async def run_test(dut, data_in=None, config_coroutine=None):
	tb = TB(dut)
	await tb.reset()
	predict_valid = 		[1]*32
	predict_pc = 			[0xA]*32
	train_valid = 			[0,1,1]+[0]*4+[1]+[0]*24
	train_taken = 			[0,1,1]+[0]*4+[0]+[0]*24
	train_mispredicted = 	[0]*32
	train_history = 		[0,0,2]+[0]*29
	train_pc = 				[0xA]*32
	for i in range(32):
		tb.dut.predict_valid.value = predict_valid[i]
		tb.dut.predict_pc.value = predict_pc[i]
		tb.dut.train_valid.value = train_valid[i]
		tb.dut.train_taken.value = train_taken[i]
		tb.dut.train_mispredicted.value = train_mispredicted[i]
		tb.dut.train_history.value = train_history[i]
		tb.dut.train_pc.value = train_pc[i]
		await RisingEdge(tb.dut.clk)
	for _ in range(4):
		await RisingEdge(tb.dut.clk)


def incrementing_payload(length=8, min=1, max=255):
	return bytes(itertools.islice(itertools.cycle(range(min, max+1)), length))


def random_payload(length=8, min=0, max=0x100):
	set = range(min, max)
	rand_set = random.sample(set, length)
	return bytes(itertools.islice(itertools.cycle(rand_set), length))


if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	# factory.add_option("data_in", [random_payload, incrementing_payload])
	factory.add_option("data_in", [random_payload])
	factory.add_option("config_coroutine", [None])
	factory.generate_tests()
