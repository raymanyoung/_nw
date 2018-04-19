# Asset ERC721 Contract Design
Asset 指的是一个用户创建的可以用在游戏中的素材资源。其它用户可以通过交易市场找到自己所需要的素材，使用 Token 购买此素材的使用权，并在**游戏**编辑器中进行创作。

**注意: 用户购买的是使用权而非所有权**

**TODO: 是否需要加入授权有效期？**

**TODO: 是否允许用户购买使用权并且进行素材的二次创作？**

**TODO: 如何防止用户进行二次销售？**

## Implementation
所有的 Asset 在创建时会保存在 IPFS 上，同时文件的 metadata 包括 IPFS hash 会保存在 ERC721 合约中。

### Asset 数据定义：

```
contract Asset {
	address 	owner;
	uint64 		createTime;
	bytes32[2] 	ipfsHash; // base58 encoded file hash
	uint32		id;
}
```

其它保存在 ERC721 的 metadata:
```
	uint32	price;  // 销售价格
```

另外一部分 metadata 属于外部数据，会保存在交易网站而非智能合约中：
```
	tags
	category
```

### 功能接口
```
	createAsset(address owner, bytes32[2] hash, uint32 price) public returns (uint32 id); // 创建Asset
	setPrice(uint32 id, uint32 price) public returns (bool success); // 设定价格
	getAsset(uint32 id) public returns (address owner, uint64 createTime, bytes32[2] ipfsHash, uint32 price);
	buyLicense(uint32 id);
	
```
