def cal(str):
	i = 0
	for c in str:
		i += map(c)

	print('result: ', i)

def map(c):
	index = ord(c)
	if index >= 48 and index <= 57: # 0 - 9
		inc = index - 48		
	if index >= 97 and index <= 122: # a-z
		inc = index - 97 + 10
	if index >= 65 and index <= 90: # A-Z
	 	inc = index - 65 + 36	
	print(c, "->", inc)
	return inc

cal("0123456789")
cal("abcdefghijklmnopqrstuvwxyz")
cal("ABCDEFGHIJKLMNOPQRSTUVWXYZ")


cal('5emNhWbvQiKZk22VoeJLL2ehsCBkx5iZLAGHvuqNEyBw')