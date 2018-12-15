pragma solidity 0.4.21;
contract ContractChecker {
	function isContract(address _addr) public view returns (bool) {
		uint length;
		assembly {
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		return (length>0);
	}
}