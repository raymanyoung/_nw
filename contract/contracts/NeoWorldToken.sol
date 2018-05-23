pragma solidity ^0.4.21;
import "./SafeMath.sol";

/*
* Contract that is working with ERC223 tokens
*/
 
contract ContractReceiver {
	function tokenFallback(address _from, uint _value, bytes _data) public pure {
	}
	function doTransfer(address _to, uint256 _index) public returns (uint256 price, address owner);
}

contract Owned {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed _from, address indexed _to);

	function Owned() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}

 /**
 * ERC223 token by Dexaran
 *
 * https://github.com/Dexaran/ERC223-token-standard
 */
 

 /* New ERC223 contract interface */
 
contract ERC223 {
	uint public totalSupply;
	function balanceOf(address who) public view returns (uint);
	
	function name() public view returns (string _name);
	function symbol() public view returns (string _symbol);
	function decimals() public view returns (uint8 _decimals);
	function totalSupply() public view returns (uint256 _supply);

	function transfer(address to, uint value) public returns (bool ok);
	function transfer(address to, uint value, bytes data) public returns (bool ok);
	
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

 
contract NeoWorldCash is ERC223, Owned {

	using SafeMath for uint256;

	mapping(address => uint) balances;
	
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;

    event Burn(address indexed from, uint256 value);
	
	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	function NeoWorldCash() public {
		symbol = "NASH";
		name = "NEOWORLD CASH";
		decimals = 18;
		totalSupply = 100000000000 * 10**uint(decimals);
		balances[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply, "");
	}
	
	
	// Function to access name of token .
	function name() public view returns (string _name) {
		return name;
	}
	// Function to access symbol of token .
	function symbol() public view returns (string _symbol) {
		return symbol;
	}
	// Function to access decimals of token .
	function decimals() public view returns (uint8 _decimals) {
		return decimals;
	}
	// Function to access total supply of tokens .
	function totalSupply() public view returns (uint256 _totalSupply) {
		return totalSupply;
	}
	
	// Function that is called when a user or another contract wants to transfer funds .
	function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
		if(isContract(_to)) {
			return transferToContract(_to, _value, _data);
		}
		else {
			return transferToAddress(_to, _value, _data);
		}
	}
	
	// Standard function transfer similar to ERC20 transfer with no _data .
	// Added due to backwards compatibility reasons .
	function transfer(address _to, uint _value) public returns (bool success) {
		//standard function transfer similar to ERC20 transfer with no _data
		//added due to backwards compatibility reasons
		bytes memory empty;
		if(isContract(_to)) {
			return transferToContract(_to, _value, empty);
		}
		else {
			return transferToAddress(_to, _value, empty);
		}
	}

	//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
	function isContract(address _addr) private view returns (bool is_contract) {
		uint length;
		assembly {
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		return (length>0);
	}

	//function that is called when transaction target is an address
	function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
		if (balanceOf(msg.sender) < _value) revert();
		balances[msg.sender] = balanceOf(msg.sender).sub(_value);
		balances[_to] = balanceOf(_to).add(_value);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}
	
	//function that is called when transaction target is a contract
	function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
	
		ContractReceiver receiver = ContractReceiver(_to);
		uint256 price;
		address owner;
		(price, owner) = receiver.doTransfer(msg.sender, bytesToUint(_data));

		if (balanceOf(msg.sender) < price) revert();
		balances[msg.sender] = balanceOf(msg.sender).sub(price);
		balances[owner] = balanceOf(owner).add(price);
		receiver.tokenFallback(msg.sender, price, _data);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	function balanceOf(address _owner) public view returns (uint balance) {
		return balances[_owner];
	}  

	function burn(uint256 _value) public returns (bool success) {
		require (_value > 0); 
		require (balanceOf(msg.sender) >= _value);            // Check if the sender has enough
		balances[msg.sender] = balanceOf(msg.sender).sub(_value);                      // Subtract from the sender
		totalSupply = totalSupply.sub(_value);                                // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	function bytesToUint(bytes b) private pure returns (uint result) {
		uint i;
		result = 0;
		for (i = 0; i < b.length; i++) {
			uint c = uint(b[i]);
			if (c >= 48 && c <= 57) {
				result = result * 10 + (c - 48);
			}
		}
	}
	
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }	
}