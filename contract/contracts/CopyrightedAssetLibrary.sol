pragma solidity ^0.4.21;
import "./ERC721Receiver.sol";
import "./SafeMath.sol";
import "./AddressUtils.sol";


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
    function Ownable() public {
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
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract ERC721BasicInterface {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public;
    
//     function name() public view returns (string _name);
//     function symbol() public view returns (string _symbol);
//     function tokenURI(uint256 _tokenId) public view returns (string);

     function totalSupply() public view returns (uint256);
//     function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
//     function tokenByIndex(uint256 _index) public view returns (uint256);
 }

contract ContractReceiver {
    function tokenFallback(address _from, uint _value, bytes _data) public ;
    function doTransfer(address _to, uint256 _index) public returns (uint256 price, address owner);
}

contract CopyrightedAssetLibInterface {

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

    function setERC223Contract(address contractAddress) public onlyOwner {
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

contract ERC721BasicToken is ERC721BasicInterface {
    
    using SafeMath for uint256;
    using AddressUtils for address;

    function addTokenTo(address _to, uint256 _tokenId) internal;
    function removeTokenFrom(address _from, uint256 _tokenId) internal ;
    function afterTransfer(uint256 _tokenId) internal;

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
    // Mapping from token ID to owner
    mapping (uint256 => address) internal tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) internal tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) internal ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    /**
     * @dev Guarantees msg.sender is owner of the given token
     * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
     */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    /**
     * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
     * @param _tokenId uint256 ID of the token to validate
     */
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

    /**
     * @dev Gets the balance of the specified address
     * @param _owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param _tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Returns whether the specified token exists
     * @param _tokenId uint256 ID of the token to query the existance of
     * @return whether the token exists
     */
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * @dev The zero address indicates there is no approved address.
     * @dev There can only be one approved address per token at a given time.
     * @dev Can only be called by the token owner or an approved operator.
     * @param _to address to be approved for the given token ID
     * @param _tokenId uint256 ID of the token to be approved
     */
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for a the given token ID
     */
    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * @dev An operator is allowed to transfer all tokens of the sender on their behalf
     * @param _to operator address to set the approval
     * @param _approved representing the status of the approval to be set
     */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param _owner owner address which you want to query the approval of
     * @param _operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * @dev Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
        unsafeTransferFrom(_from, _to, _tokenId);
    }

    function unsafeTransferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_from != address(0));
        require(_to != address(0));       

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);
        afterTransfer(_tokenId);
        
        emit Transfer(_from, _to, _tokenId);       
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * @dev If the target address is a contract, it must implement `onERC721Received`,
     *  which is called upon a safe transfer, and return the magic value
     *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
     *  the transfer is reverted.
     * @dev Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        canTransfer(_tokenId)
    {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * @dev If the target address is a contract, it must implement `onERC721Received`,
     *  which is called upon a safe transfer, and return the magic value
     *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
     *  the transfer is reverted.
     * @dev Requires the msg sender to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        public
        canTransfer(_tokenId)
    {
        transferFrom(_from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param _spender address of the spender to query
     * @param _tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *  is an operator of the owner, or is the owner of the token
     */
    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
    }

    /**
     * @dev Internal function to clear current approval of a given token ID
     * @dev Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }


    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * @dev The call is not executed if the target address is not a contract
     * @param _from address representing the previous owner of the given token ID
     * @param _to target address that will receive the tokens
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        internal
        returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

}

contract CopyrightedAssetLibrary is ERC721BasicToken, CopyrightedAssetLibInterface, WithExternalERC223, ContractReceiver, Pausable  {

    struct Asset {
        uint256     createTime;
        bytes       ipfsHash; // base58 encoded file hash
    }

    mapping (bytes => address) hashOwner;
    mapping (uint256 => uint256) tokenPrice; // if set to 0 it means not for sale
    mapping (address => uint256[]) ownedAssetIds;

    address public _supportedToken;

    Asset[] allAssets;

    event Log(string text);
    event Log(uint text);
    event Log(address text);

    event AssetCreated(address from, uint256 id);

    function createAsset(address from, bytes hash, uint256 price) public returns (uint256 id) { // 创建Asset
        require(hash.length > 0);
        require(hashOwner[hash] == 0);

        Asset memory asset = Asset({
            createTime: block.timestamp,
            ipfsHash: hash
            });

        uint256 newid = allAssets.push(asset) - 1;
        require(newid == uint256(uint32(newid)));

        tokenPrice[newid] = price;

        addTokenTo(from, newid);
        emit AssetCreated(from, newid);
    }

    function setPrice(uint256 tokenId, uint256 price) public returns (bool success) { // 设定价格
        require(tokenOwner[tokenId] == msg.sender);
        tokenPrice[tokenId] = price;
    }

    function totalSupply() public view returns (uint256) {
        return allAssets.length;
    }

    function getAssetInfo(uint256 id) public view returns (uint256 tokenId, address owner, uint256 createTime, bytes hash, uint256 price) {
        tokenId = id;
        owner = tokenOwner[id];
        createTime = allAssets[id].createTime;
        hash = allAssets[id].ipfsHash;
        price = tokenPrice[id];
    }

    function getOwnedTokens(address _address) public view returns (uint256[] ids) {
        return ownedAssetIds[_address];
    }    

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
        hashOwner[allAssets[_tokenId].ipfsHash] = _to;
        ownedAssetIds[_to].push(_tokenId);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);
        removeFromOwnedIds(_from, _tokenId);
    }

    function removeFromOwnedIds(address _address, uint256 _tokenId) internal {
        for (uint i = 0; i < ownedAssetIds[_address].length; i++) {
            if (ownedAssetIds[_address][i] == _tokenId) {
                ownedAssetIds[_address][i] = ownedAssetIds[_address][ownedAssetIds[_address].length - 1];
                delete ownedAssetIds[_address][ownedAssetIds[_address].length - 1];
                ownedAssetIds[_address].length--;
            }
        }
    }

    function buy(uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) != msg.sender) ;
        require(tokenPrice[_tokenId] > 0);
        require(msg.value >= tokenPrice[_tokenId]);

        address originalOwner = tokenOwner[_tokenId];
        unsafeTransferFrom(tokenOwner[_tokenId], msg.sender, _tokenId);

        originalOwner.transfer(tokenPrice[_tokenId]);

        if (msg.value > tokenPrice[_tokenId]) {
            msg.sender.transfer(msg.value - tokenPrice[_tokenId]);
        }
    }

    function setSupportedToken(address contractAdress) public {
        require(contractAdress != address(0));
        _supportedToken = contractAdress;
    }
        
    function afterTransfer(uint256 _tokenId) internal {
        tokenPrice[_tokenId] = 0;
    }    

    function doTransfer(address _to, uint256 _index) public returns (uint256 price, address owner) {
        require(_supportedToken != address(0) && msg.sender == _supportedToken);
        require(tokenPrice[_index] > 0);
        price = tokenPrice[_index];
        owner = tokenOwner[_index];
        unsafeTransferFrom(tokenOwner[_index], _to, _index);
    }

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

    function bytesToUint(bytes b) private pure  returns (uint result) {
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    function addressToString(address x) private pure returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function intToString(uint n) private pure returns (string) {
        bytes memory bytesString = new bytes(1);
        byte char = byte(bytes32(n));
        if (char != 0) {
            bytesString[0] = char;
        }
        return string(bytesString);
    }

    function bytes32ToString (bytes32 data) private pure  returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }    

    function char(byte b) private pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}
