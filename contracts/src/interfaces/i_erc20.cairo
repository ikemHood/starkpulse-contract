#[starknet::interface]
trait IERC20<TContractState> {
    // Standard ERC20 functions
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: starknet::ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: starknet::ContractAddress, spender: starknet::ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: starknet::ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, 
        sender: starknet::ContractAddress, 
        recipient: starknet::ContractAddress, 
        amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: starknet::ContractAddress, amount: u256) -> bool;
    
    // CamelCase variants (for compatibility)
    fn totalSupply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: starknet::ContractAddress) -> u256;
    fn transferFrom(
        ref self: TContractState, 
        sender: starknet::ContractAddress, 
        recipient: starknet::ContractAddress, 
        amount: u256
    ) -> bool;
} 