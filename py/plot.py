"""
MTU		Octet		Single		Line Rate
64		135684.08 	19318.17	154545.38 
68		143665.52 	19565.14	156521.14 
72		151646.88 	19791.59	158332.72 
76		159628.32 	19999.92	159999.38 
80		161537.76 	20192.23	161537.84 
84		162962.24 	20370.29	162962.34 
88		164284.96 	20535.64	164285.09 
96		166666.00 	20833.25	166666.03 
112		170587.52 	21323.45	170587.59 
128		173683.52 	21710.45	173683.56 
160		178260.16 	22282.53	178260.20 
192		181480.72 	22685.10	181480.81 
256		185713.54 	23214.20	185713.60 
384		190195.33 	23774.42	190195.38 
512		192536.80 	24067.08	192536.61 
1024	196182.64 	24522.81	196182.49 
1400	197190.48 	24648.79	197190.29 
9000	199556.08 	24944.50	199556.01 
"""

from mpl_toolkits.mplot3d import axes3d	# used for scatter
from matplotlib import style
import matplotlib.pyplot as plt
import numpy as np

"""
filename: plot.py
[]: https://matplotlib.org/1.5.3/users/style_sheets.html	""
"""


def f_plot_1():
	pktlen = [64, 68, 72, 76, 80, 84, 88, 96, 112,
           128, 160, 192, 256, 384, 512, 1024, 1400, 9000]
	octet = [135684.08, 143665.52, 151646.88, 159628.32, 161537.76, 162962.24, 164284.96, 166666.00, 170587.52,
          173683.52, 178260.16, 181480.72, 185713.54, 190195.33, 192536.80, 196182.64, 197190.48, 199556.08]
	single = [19318.17, 19565.14, 19791.59, 19999.92, 20192.23, 20370.29, 20535.64, 20833.25, 21323.45,
           21710.45, 22282.53, 22685.10, 23214.20, 23774.42, 24067.08, 24522.81, 24648.79, 24944.50]
	tx_rate = [19047.619, 19318.182, 19565.217, 19791.667, 20000.000, 20192.308, 20370.371, 20689.655, 21212.121,
            21621.622, 22222.222, 22641.509, 23188.406, 23762.376, 24060.151, 24521.072, 24647.887, 24944.568]
	line_rate = 25.78125  # for F1000
	# line_rate = 25			# for IXIA

	y_1 = [i/1e3 for i in octet]
	y_2 = [i*8/1e3 for i in single]
	y_3 = [i*8/1e3 for i in tx_rate]					# Tx Rate = TX Rate UB
	y_4 = [r*8/1e3*(pktlen[i]+4.0)/pktlen[i]
            for i, r in enumerate(tx_rate)]  # Expected RX rate = RX Rate UB
	y_5 = [(i)/(i+20)*(line_rate*8) for i in pktlen]		# TX Rate UB
	y_6 = [(i+4)/(i+20)*(line_rate*8) for i in pktlen]				# RX Rate UB, ERROR!
	y_7 = [ub if ub < y_4[i] else y_4[i] for i, ub in enumerate(y_5)]

	fig = plt.figure(figsize=[9.6, 4.8])  # purple
	plt.plot(pktlen, y_1, color='black', marker='.', label="octet")
	plt.plot(pktlen, y_2, color='blue', marker='.', label="single×8")
	plt.plot(pktlen, y_3, color='orange', marker='.', label="tx rate")
	plt.plot(pktlen, y_4, color='pink', marker='.', label="expected RX rate")
	plt.plot(pktlen, y_5, color='yellow', marker='.', label="RX rate UB")
	plt.plot(pktlen, y_7, color='red', marker='.', label="upper bound")

	plt.grid()
	plt.legend()
	# plt.xscale('log2')
	plt.semilogx(base=2)
	plt.xlim(64, 1500)
	plt.ylim(130, 210)
	plt.xlabel('Frame size (B)')
	plt.ylabel('Thoughput (Gbps)')
	plt.title('Thoughput - Frame size')

	# function to show the plot
	return


def plot_bar():
	left = [1, 2, 3, 4, 5]
	height = [10, 24, 36, 40, 5]
	tick_label = ['one', 'two', 'three', 'four', 'five']
	plt.bar(left, height, tick_label=tick_label,
			width=0.8, color=['red', 'green'])	# color set one by one

def plot_histogram():
	ages = [2, 5, 70, 40, 30, 45, 50, 45, 43, 40, 44,
		 60, 7, 13, 57, 18, 90, 77, 32, 21, 20, 40]
	# setting the ranges and no. of intervals
	range = (0, 100)
	bins = 10
	plt.hist(ages, bins, range, color='green',
			histtype='bar', rwidth=0.8)

def plot_scatter():
	x = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	y = [2, 4, 5, 7, 6, 8, 9, 11, 12, 12]
	plt.scatter(x, y, marker="*", s=30)	# size: s.

def plot_pie():
	"""
	explode is used to set the fraction of radius with which we offset each wedge.
	autopct is used to format the value of each label. Here, we have set it to show the percentage value only upto 1 decimal place
	"""
	activities = ['eat', 'sleep', 'work', 'play']
	# portion covered by each label
	slices = [3, 7, 8, 6]
	colors = ['r', 'y', 'g', 'b']
	plt.pie(slices, labels = activities, colors=colors, 
			startangle=90, shadow = True, explode = (0, 0, 0.1, 0),
			radius = 1.2, autopct = '%1.1f%%')

# function to generate coordinates


def create_plot(ptype):
	# setting the x-axis values
	x = np.arange(-10, 10, 0.01)

	# setting the y-axis values
	if ptype == 'linear':
		y = x
	elif ptype == 'quadratic':
		y = x**2
	elif ptype == 'cubic':
		y = x**3
	elif ptype == 'quartic':
		y = x**4

	return(x, y)


def plot_subplot():
	# setting a style to use
	plt.style.use('fivethirtyeight')

	# create a figure
	fig = plt.figure(fontsize=20, figsize=[9.6, 4.8])
	plt.grid()

	# define subplots and their positions in figure
	plt1 = fig.add_subplot(221)
	plt2 = fig.add_subplot(222)
	plt3 = fig.add_subplot(223)
	plt4 = fig.add_subplot(224)

	# plotting points on each subplot
	x, y = create_plot('linear')
	plt1.plot(x, y, color='r')
	plt1.set_title('$y_1 = x$')

	x, y = create_plot('quadratic')
	plt2.plot(x, y, color='b')
	plt2.set_title('$y_2 = x^2$')

	x, y = create_plot('cubic')
	plt3.plot(x, y, color='g')
	plt3.set_title('$y_3 = x^3$')

	x, y = create_plot('quartic')
	plt4.plot(x, y, color='k')
	plt4.set_title('$y_4 = x^4$')

	# adjusting space between subplots
	fig.subplots_adjust(hspace=.5, wspace=0.5)


# function to generate coordinates
def create_plot(ptype):
    # setting the x-axis values
    x = np.arange(0, 5, 0.01)

    # setting y-axis values
    if ptype == 'sin':
        # a sine wave
        y = np.sin(2*np.pi*x)
    elif ptype == 'exp':
        # negative exponential function
        y = np.exp(-x)
    elif ptype == 'hybrid':
        # a damped sine wave
        y = (np.sin(2*np.pi*x))*(np.exp(-x))

    return(x, y)


def plot_subplot2grid():
	# setting a style to use
	plt.style.use('ggplot')

	# defining subplots and their positions
	plt1 = plt.subplot2grid((11, 1), (0, 0), rowspan=3, colspan=1)
	plt2 = plt.subplot2grid((11, 1), (4, 0), rowspan=3, colspan=1)
	plt3 = plt.subplot2grid((11, 1), (8, 0), rowspan=3, colspan=1)

	# plotting points on each subplot
	x, y = create_plot('sin')
	plt1.plot(x, y, label='sine wave', color='b')
	x, y = create_plot('exp')
	plt2.plot(x, y, label='negative exponential', color='r')
	x, y = create_plot('hybrid')
	plt3.plot(x, y, label='damped sine wave', color='g')

	# show legends of each subplot
	plt1.legend()
	plt2.legend()
	plt3.legend()

def plot_3dimen():
	# setting a custom style to use
	style.use('ggplot')

	# create a new figure for plotting
	fig = plt.figure()

	# create a new subplot on our figure
	# and set projection as 3d
	ax1 = fig.add_subplot(221, projection='3d')
	ax2 = fig.add_subplot(222, projection='3d')
	ax3 = fig.add_subplot(223, projection='3d')
	ax4 = fig.add_subplot(224, projection='3d')

	# defining x, y, z co-ordinates
	x = np.random.randint(0, 10, size=20)
	y = np.random.randint(0, 10, size=20)
	z = np.random.randint(0, 10, size=20)

	# plotting the points on subplot
	ax1.scatter(x, y, z, c='m', marker='o')
	# ax2.plot_wireframe(x,y,z)

	# defining x, y, z co-ordinates for bar position
	x = [1,2,3,4,5,6,7,8,9,10]
	y = [4,3,1,6,5,3,7,5,3,7]
	z = np.zeros(10)
	# size of bars
	dx = np.ones(10)              # length along x-axis
	dy = np.ones(10)              # length along y-axs
	dz = [1,3,4,2,6,7,5,5,10,9]   # height of bar
	# setting color scheme
	color = []
	for h in dz:
		if h > 5:
			color.append('r')
		else:
			color.append('b')
	# plotting the bars
	ax3.bar3d(x, y, z, dx, dy, dz, color=color)

	# get points for a mesh grid
	u, v = np.mgrid[0:2*np.pi:200j, 0:np.pi:100j]
	# setting x, y, z co-ordinates
	x=np.cos(u)*np.sin(v)
	y=np.sin(u)*np.sin(v)
	z=np.cos(v)
	ax4.plot_wireframe(x, y, z, rstride = 5, cstride = 5, linewidth = 1) 

	# setting labels for the axes
	ax1.set_xlabel('x-axis', fontsize=20)
	ax1.set_ylabel('y-axis')
	ax1.set_zlabel('z-axis')

def plot_log():
	"""
	nonposx='clip', nonposy='clip'
	"""
	t = [i for i in range(100)]
	x = [2**i for i in range(100)]
	y = [10**i for i in range(100)]

	fig = plt.figure()
	plt1 = fig.add_subplot(221)
	plt2 = fig.add_subplot(222)
	plt3 = fig.add_subplot(223)
	plt4 = fig.add_subplot(224)

	plt1.loglog(x, y, marker='.', base=2, basey=10)
	# plt2.semilogx(base=2)
	# plt2.semilogy(base=10)
	plt.plot(t, y, marker='.')
	plt.yscale('log')


if(__name__ == "__main__"):
	f_plot_1()
	plt.show()
