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
	print('地块序号:' , i % 90 + 1)

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

data = ['b420f3eb37a9c7ce2e22de7a6a6d6b46205dedfebea86d16f7c30027552249aa', \
	'995874c1af09ab3add7f2ff313c1ad5e717ed976a1f799acb187a18b9cb11f14', \
	'abb40faa05a1a9a97a48520078dd1a583d9a899c803c58816cf9ae69eabf4e99', \
	'd774c0940b3bb4dd37d54a16ed2ee8cff0a0fcc6b93156d90560b24a97bf3bd8', \
	'1ba8e784284cf3633a1729c32177872442149401e305e3f43b72f7a72915d7e3', \
	'ea056d1b260b58fd586434f35498c8a1853691e67fb839efb060d6bc8d43eed0', \
	'3647a4a855819bb1ba11e7da6c7079a1e2f6ad9333300cc9b933876a70ba7c4a', \
	'321b2f8c59372ff55c96ee4f668579c8f02fc9c011ef16d59e74124352c7efe3', \
	'f6bd6b98c5922ee92ced5a2add53c23409739f135f9dacaf7566ccf28fa95eac', \
	'27fc01ccf6874c9e4ce00a9ced73ce9b3d8b09c523b53476c169005e71119bd1', \
	'de00345a3cfd88c0ba1ea3e19b2c27025e58047ccb2564c0857e0f160de33d8a', \
	'0a1a5fbf5647cb476a1072ae5e0bea918309ee344738a323d7595cec1e2e6789', \
	'0c765a244c50529f532e3d519add63501fdd798473d6df284da9fc14b7b6edde', \
	'82863577e455f39ad9a83c04354be4a4d0652626b08f63565b3ba65320e119a4', \
	'4676f7720084c5b14f9b3a98414bf9a38e1c7837107f8fcc093bd9756aa24f31', \
	'bb0fe91528781d92c969c89dc856a2cee4723851b2e85e51cfb949377e8dc4b3', \
	'03321f758028e031e5a41f1bcd5c0576c053c647a578e15db0fda56ba7eb4ea1', \
	'2ef68fcc98f31f2237ef7bc0167ad76656c22492c2308d99f4f472f315805856', \
	'83e134dc09cd1e11cf9a5b6b39432a322dfed8eda81fb46364aab6d0060e9352', \
	'4b3087a9dd497ecd44c786ea38938d686a643f556f78b57c3dfb329c3f8883fa', \
	'5e4b887a2ecb937517664420235c669cab5e2b7a4e2d650de4414bec3d9700d0', \

]

for hash1 in data:
 	cal(hash1)
#cal('5cCrnLhtLjFB8t3Ntm5J5ifq3op76QSNTo11T4mz6KFU')