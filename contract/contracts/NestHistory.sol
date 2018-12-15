pragma solidity 0.4.21;

contract NestHistory {
	enum Mode { BUY, SELL }
	event Transaction (Mode mode, 
		uint256 nestAmount, 
		uint256 nashAmount,
		uint256 nashReserved,
		uint256 nestSupply,
		bool isOfficial);

	 function emitTransaction (Mode mode, 
		uint256 nestAmount, 
		uint256 nashAmount,
		uint256 nashReserved,
		uint256 nestSupply,
		bool isOfficial) public {

		emit Transaction(
			mode, 
			nestAmount,
			nashAmount,
			nashReserved,
			nestSupply,
			isOfficial);
	}
}
