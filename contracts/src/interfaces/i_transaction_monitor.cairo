#[starknet::interface]
trait ITransactionMonitor<TContractState> {
    fn register_transaction(
        ref self: TContractState, 
        tx_hash: felt252, 
        tx_type: felt252, 
        amount: u256
    ) -> bool;
    fn get_transaction_history(self: @TContractState, user_address: starknet::ContractAddress) -> Array<Transaction>;
    fn get_transaction_details(self: @TContractState, tx_hash: felt252) -> Transaction;
}

#[derive(Drop, Serde)]
struct Transaction {
    tx_hash: felt252,
    user: starknet::ContractAddress,
    tx_type: felt252,
    amount: u256,
    timestamp: u64,
}