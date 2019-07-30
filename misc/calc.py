def cal(str):
	i = 0
	#index = 1
	index = 7
	for c in str:
		i += map(c) * index
#		print(c, '=>', map(c), " x " , index)

		index += 10

	print('HASH:', str)
	print('转化数字: ', i)
	print('地块序号:' , i % 90)

def map(c):
	index = ord(c)
	if index >= 48 and index <= 57: # 0 - 9
		inc = index - 48		
	if index >= 97 and index <= 122: # a-z
		inc = index - 97 + 10
	if index >= 65 and index <= 90: # A-Z
	 	inc = index - 65 + 36	
#	print(c, "->", inc)
	return inc

#cal("0123456789")
#cal("abcdefghijklmnopqrstuvwxyz")

data = ['257a608e25ec2fb8f38dad6fae3cfbe14ffe70f582cdc97ab1bced5a6885ea2a', \
	'4582dbb1577f1e1766a1822c16b946c810496ca7244e0a0602daddcb1542752f', \
]

for hash1 in data:
 	cal(hash1)
#cal('5cCrnLhtLjFB8t3Ntm5J5ifq3op76QSNTo11T4mz6KFU')