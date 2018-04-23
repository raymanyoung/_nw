pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ERC223 {
  function balanceOf(address who) public view returns (uint);
  
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function decimals() public view returns (uint8 _decimals);
  function totalSupply() public view returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
  
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

 contract ContractReceiver {
    function tokenFallback(address _from, uint _value, bytes _data) ;
 }


 contract CopyrightedAssetLibInterface is ERC223 {

    // function issueLicenseTo(address _to, uint256 _tokenId) external;
    // function isHavingLicense(address _add, uint256 _tokenId) external view returns (bool);

    // Events
    event TransferOwnership(address from, address to, uint256 tokenId);
    /// Emited when the license of an asset is issued to a buyer
    event IssueLicense (address from, address to, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    // function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

contract WithExternalERC223 is Ownable {
    address _supportedToken;

    function setERC223Contract(address contractAddress) onlyOwner {
        _supportedToken = contractAddress;
    }

    modifier supportedToken(address tokenAddress) { 
      require (_supportedToken != address(0) && tokenAddress == _supportedToken); 
      _; 
    }
    
}

/// @title A facet of KittyCore that manages special access privileges.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract Pausable is Ownable{

    event ContractUpgrade(address newContract);


    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyOwner whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyOwner whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

contract CopyrightedAssetLibrary is CopyrightedAssetLibInterface, WithExternalERC223, ContractReceiver, Pausable {
    mapping (uint => address) tokenOwners;
    mapping (address => uint256) ownershipTokenCount;
    mapping (bytes => address) hashOnwer;
    mapping (uint => uint32) tokenPrice;
    
    struct Asset {
      uint256    createTime;
      bytes  ipfsHash; // base58 encoded file hash
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of kittens is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        tokenOwners[_tokenId] = _to;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId, "");
    }

    Asset[] allAssets;
    
    function createAsset(address from, bytes hash, uint32 price) public onlyOwner returns (uint32 id) { // 创建Asset
      require(hash.length > 0);
      require(hashOnwer[hash] == 0);
      require(price > 0);

      Asset memory asset = Asset({
        createTime: block.timestamp,
        ipfsHash: hash
        });

      uint256 newid = allAssets.push(asset) - 1;
      require(newid == uint256(uint32(newid)));

      _transfer(address(0), from, newid);
    }

    function setPrice(address from, uint tokenId, uint32 price) public onlyOwner returns (bool success) { // 设定价格
      require(tokenOwners[tokenId] == from);
      tokenPrice[tokenId] = price;
    }

    function getAssetInfo(uint id) public returns (address owner, uint256 createTime, uint32 price) {
      owner = tokenOwners[id];
      createTime = allAssets[id].createTime;
      price = tokenPrice[id];
    }

    function name() public view returns (string _name) {
      _name = "SAL";
    }

    function symbol() public view returns (string _symbol) {
      _symbol = "SAL";
    }
    
    function decimals() public view returns (uint8 _decimals) {
      _decimals = 0;
    }

    function totalSupply() public view returns (uint256 _supply) {
      _supply = 100;
    }
    
    function balanceOf(address who) public view returns (uint) {
      return ownershipTokenCount[who];
    }
    
    function ownerOf(uint _tokenId) external view returns (address owner) {
      owner = tokenOwners[_tokenId];
    } 

    function transfer(address to, uint value) public returns (bool ok) {}
    function transfer(address to, uint value, bytes data) public returns (bool ok) {}
    function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok) {}

    function tokenFallback(address _from, uint _value, bytes _data) public {
      // TKN memory tkn;
      // tkn.sender = _from;
      // tkn.value = _value;
      // tkn.data = _data;
      // uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      // tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */


    }
}
