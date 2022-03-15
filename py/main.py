import struct
import string
import itertools

try: import note
except ImportError:
	sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
	try:
		import note
	finally:
		del sys.path[0]

def test_bytearray():
	int_1 = struct.unpack('>1H', b'\x01\x0F')
	print(int_1)
	list_1 = [1, 2, 3, 4]
	bytes_1 = bytes(list_1)
	print(bytes_1)
	bytearray_1 = bytearray(list_1)
	print(bytearray_1)
	bytes_1 = bytes(3)
	print(bytes_1)
	bytearray_1 = bytearray(3)
	print(bytearray_1)
	tcam_data = []
	for i in range(8):
		t = bytearray.fromhex('C0A80101%02d' % (i%0x100))
		tcam_data.append(t)
	tcam_addr = 0x00
	return

def test_string():
	# bytearray_1 = bytearray(range(0, 0xFF))
	# print(bytearray_1)
	# bytearray_1 = bytearray([1,2,3,4])
	# print(bytearray_1)
	# str_1 = bytearray_1.decode('utf-8')
	# print(str_1)
	# str_2 = str_1.split('0')  # 分割
	# print(str_2)
	int_1 = 0xDA_D1_D2_D3_D4_D5
	len_1 = int_1.bit_length()
	print(int_1)
	print(int_1.bit_length())
	list_1 = [(int_1 >> (i-1)*8) % 0x100 for i in range(len_1//8, 0, -1)]
	print(list_1)
	for i in list_1:
		print(type(i))
		print(hex(i))

	return
	str_1 = hex(int_1)
	print(str_1)
	bytearray_1 = bytearray(str_1[2:], encoding='utf-8')
	print(bytearray_1)
	bytearray_1 = bytearray()


def cycle_pause():
	return itertools.cycle([1, 1, 1, 0])

def test_generator():
	for i in cycle_pause():
		print(i)

if(__name__ == "__main__"):
	test_generator()

