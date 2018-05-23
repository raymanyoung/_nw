pragma solidity ^0.4.21;
import "./SafeMath.sol";

 /*
 * Contract that is working with ERC223 tokens
 */
 
 contract ContractReceiver {
     
    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    
    function tokenFallback(address _from, uint _value, bytes _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }

    function doTransfer(address _to, uint256 _index) public returns (uint256 price, address owner);
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
//  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
  
  event Transfer(address indexed from, address indexed to, uint tokens);
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

 
contract NeoWorldCash is ERC223 {

  using SafeMath for uint256;

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  
  // ------------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------------
  function NeoWorldCash() public {
      symbol = "NASH";
      name = "NEOWORLD CASH";
      decimals = 18;
      totalSupply = 7600000000 * 10**uint(decimals);
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
  // function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
  //   Log("tranfer param 4");
      
  //   if(isContract(_to)) {
  //       if (balanceOf(msg.sender) < _value) revert();
  //       balances[msg.sender] = balanceOf(msg.sender).sub(_value);
  //       balances[_to] = balanceOf(_to).add(_value);
  //       require(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
  //       emit Transfer(msg.sender, _to, _value, _data);
  //       return true;
  //   }
  //   else {
  //       return transferToAddress(_to, _value, _data);
  //   }
  // }
  

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

  //   function addressToString(address x) private pure returns (string) {
  //       bytes memory s = new bytes(40);
  //       for (uint i = 0; i < 20; i++) {
  //           byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
  //           byte hi = byte(uint8(b) / 16);
  //           byte lo = byte(uint8(b) - 16 * uint8(hi));
  //           s[2*i] = char(hi);
  //           s[2*i+1] = char(lo);            
  //       }
  //       return string(s);
  //   }
  //       function char(byte b) private pure returns (byte c) {
  //       if (b < 10) return byte(uint8(b) + 0x30);
  //       else return byte(uint8(b) + 0x57);
  //   }

  // function uintToString(uint i) internal pure returns (string){
  //     if (i == 0) return "0";
  //     uint j = i;
  //     uint length;
  //     while (j != 0){
  //         length++;
  //         j /= 10;
  //     }
  //     bytes memory bstr = new bytes(length);
  //     uint k = length - 1;
  //     while (i != 0){
  //         bstr[k--] = byte(48 + i % 10);
  //         i /= 10;
  //     }
  //     return string(bstr);
  // }

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
}