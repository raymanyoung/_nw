pragma solidity 0.4.21;

library ContractLib {
	//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
	function isContract(address _addr) internal view returns (bool) {
		uint length;
		assembly {
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		return (length>0);
	}
}