#[starknet::interface]
trait IPortfolioTracker<TContractState> {
    fn add_asset(ref self: TContractState, asset_address: starknet::ContractAddress, amount: u256) -> bool;
    fn remove_asset(ref self: TContractState, asset_address: starknet::ContractAddress, amount: u256) -> bool;
    fn get_portfolio(self: @TContractState, user_address: starknet::ContractAddress) -> Array<Asset>;
    fn get_portfolio_value(self: @TContractState, user_address: starknet::ContractAddress) -> u256;
}

#[derive(Drop, Serde)]
struct Asset {
    address: starknet::ContractAddress,
    amount: u256,
    last_updated: u64,
}