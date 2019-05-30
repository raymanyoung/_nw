def cal(str):
	i = 0
	#index = 1
	index = 7
	for c in str:
		i += map(c) * index
		print(c, '=>', map(c), " x " , index)

		index += 10

	print('总和: ', i)
	print('地块ID:' , i % 900)

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

data = ['F4kcHVvX36X6rY1NkmNguWsBHKRBV2sez6xmoYvYd3SF', \
	'2xmA7ph9CNhU9UBgPCE1Xtg9xfRC7pQixqvz3ALDbXTA', \
	'CAvehVXgk8T4WVjtjVUkcRXKfLZnFkzZHYTG5vm246fn', \
	'3Q8AN9SraYpfnne3wJFm13fTwsNuZdGHhp3JaM4Y4ZPo', \
	'DDdZxNeQvrLmGJn19Vn7sNHaS7CCt1rK6CV4xv2Vga2E', \
	'DryVvqNd8t8JhsQ6vqfAR5eBT6zXvG5FR82a93murzHS', \
	'6YAewQJ7gJGTLZHcy242KbTKCmKLS6dAdFsNbcj9f8WL', \
	'8JiFcQSNJBrkVMQ72oGDfLksha3RovRpdTJYktbgAgmb', \
	'8D4HdiiY8gvhFCivZ23Np7AyeZsSN6XimMp4DRfnj2S1', \
	'G1oWRGugsRABwBtvp86dpkxwMxNgjfNaYSwm3UoKNMq2', \
	'66xeFfmVcpH1rXsKJkWkCovDtcqGCiocoe9nQpi2YJcR', \
	'DhV3K6xWJvkAT96xS2J5Uaz1oyQ2yFx6vLK5KbFptgDu', \
	'8cPaQ8X2axiJac2F1s27G3TWxfeAqjnjKYML2uHwb6EN', \
	'FTm2CZAUYa3pgBtFxb6qDiP12BSjrgNza5FYz9QHz91Q', \
	'5vfB2QtdMZcnxfRmvnukhfd9BDEucxKuPF9KkYuPtZuE', \
	'G36LTh8e9gksmXunvVpenjv1zGRMjgbftJE366Utf52w', \
	'BiFfq4JnotLQ23sqGqkycaRU1oRH5CnCRDjqtzSiKMaD', \
	'9QUc6KZVQgyHVR7dcTL3AE4zrWoZ1L3196SC7wzhcTqm', \
	'Hmco97f8RDLpGt8EvocbLzrsfdyeGt9ECdwZZTErzEqH', \
	'C7A6fwFW6f1EfQwdN9HTiZ5CpvtJe86gkpG9X24sLhRh', \
	'DuqReScZ3zxVPcDCgMDM25fd7esEmMJ2EfnkMtrEJg8r', \
	't8NjS53QrckxUo8HYSzHLGFaKJLx2cwjHrjCS3GruMC', \
	'DKvxkYLi2sGQHzn3eLzZEieaijHFrHsysnJuBvbz13Rj', \
	'EFwNdLE8EuFSN7RMvTxFP6LHPF9PF98YfPz5cZeNhrmC', \
	'9vBPDNRU4e1GbbF8t2dMcCd5k5sKPC5R5Qfv6Hvcarra', \
	'E2bvqQLYbJL7wkwTAcdidJcrfDx1XjJ4HfzYkBbkTq5x', \
	'9wPxJNed9mZvz7rkZZBCk4XhaCtjD282JTNVMWVkhfxV', \
	'9WaQ2BkDtjaEhR7TSNyFu5Nww9Q4PkkokWtb4YT9tJ3r', \
	'BJUPbPH7pWmuD6tXsJM2HXzM1BXq46XEkZYnx55PgYVB', \
	'DNRU3wiXPNtLQWwYXKtv6TAd2VvHPeXR8dkqZX619uJG', \
	'G9Ad1MHy6FiShL3RvQvt1C1SLMCSXhNuYiWPMAr5NGoh', \
	'GY31mNP2yJxDH4MEUxJEKAuFd1fAVvtkjtNcVtcd3P2a', \
	'FMusQmzvm5JKABDvSFJbkQ5iAUMp1LC8XqeZrtvbSjVR', \
	'9vq9TX5SJoTfLPomawmEk7FezxmYE13r74w9G5hf7eKb', \
	'JECeNHHo5Ka9SjpwDNfWWzKSDDZ1FdugD2zrGhwYBW5n', \
	'5BsozSR912s6R2XaCSN4ETb7DJ4gqfKoZatZFrycS5Nu', \
	'G92m1f8uSGmsqUHd9vFHo3K6mF3CZ26BhcBfrcuFnTR6', \
	'33AUaSKTR41q8hFEsePoiAR7uabMnfYGQSdiY6VtWFDZ', \
	'ExTpLNfqSmPFVzL4foG7mF3SeS9tNZs6qDcDh2kigdqA', \
	'2kUoXYPBShm3S3w2Mt1CnjamhfcVNDFcjQmQY3a63V8N', \
	'6MVRxrWPDMjwpQbPUNmbbA4gWP7XX2VLdtxy8knkwvH6', \
	'14jRDhEQ7XnqA9UUY6qmq7LEEDkvfGKU6GZGHrFuoHRB', \
	'6cKE4oZYDuva7rBbeef11qAaB2VQ8m76Hq4xy9tmNntM', \
	'5dYp7f7FidNJvkWqVodPsWCCzdfJo1yLWntHcsqoYJmL', \
	'ACP3JKT863mCVeQW8yjmog8RjoWVi1QiEPfWbdiwLv9i', \
	'CAnaU6Pe3XKNzJc4nnCDoTJU5RwndxVysYeUP6zwMMMV', \
	'3u4bm1XxDQdM2LF315hJXzjMqNmYFeQ2foNeCRVJMckc', \
	'9YQznX2XPPw8jVmoKs5MY5P8krqaycabV2fo2W187N7f', \
	'7gfd68hUg9QUHtaSCNNX4jTiGcL5ChMuZaMjVw5ZBH6d', \
	'Er2vp7mUCif55vgYsrtrUZ4Hn2pGJVgTX23VsJRTvgQM', \
	'6QRzBEpgtsuzPVfBWBij18zrtWvS6wL1EHWst41hwe9z' \
]

# for hash1 in data:
# 	cal(hash1)
cal('5emNhWbvQiKZk22VoeJLL2ehsCBkx5iZLAGHvuqNEyBw')