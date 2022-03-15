#
# Created on Tue Jan 18 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	 testbench.py
# @Author:		 Jiawei Lin
# @Last edit:	 11:16:42
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
		self.DEPTH = self.dut.DEPTH.value
		self.DATA_WIDTH = self.dut.DATA_WIDTH.value
		self.CL_DATA_WIDTH = self.dut.CL_DATA_WIDTH.value
		self.KEEP_WIDTH = self.dut.KEEP_WIDTH.value
		self.CL_KEEP_WIDTH = self.dut.CL_KEEP_WIDTH.value
		self.log.debug("DATA_WIDTH = %d" % self.DEPTH)
		self.log.debug("DATA_WIDTH = %d" % self.DATA_WIDTH)
		self.log.debug("CL_DATA_WIDTH = %d" % self.CL_DATA_WIDTH)
		self.log.debug("KEEP_WIDTH = %d" % self.KEEP_WIDTH)
		self.log.debug("CL_KEEP_WIDTH = %d" % self.CL_KEEP_WIDTH)

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	def model(self, din):
		"""Model of FracTCAM"""
		din = int.from_bytes(din, byteorder='big')
		din_i = []
		out_1 = din
		for i in range(self.WIDTH):
			din_i.append(din >> (i*self.DEPTH))
			out_1 = out_1 & din_i[i]
		return out_1

	async def reset(self):
		self.dut.in_1.value = 0
		self.log.info("Reset begin...")
		self.dut.rst.setimmediatevalue(0)
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.rst <= 1
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.rst.value = 0
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.log.info("reset end")


async def run_test(dut, data_in=None, config_coroutine=None):
	tb = TB(dut)
	await tb.reset()
	return
	# if config_coroutine is not None:	# TODO: config match rules
	# cocotb.fork(config_coroutine(tb.csr))

	for din in range(0, 0xFF, 0x1):
		tb.dut.in_1.value = din % (1<<tb.WIDTH)
		tb.log.debug("%s", repr(hex(din)))
		aa = tb.dut.wire_1.value
		tb.log.debug("%s", repr(aa))
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
