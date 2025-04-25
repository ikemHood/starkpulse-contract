use starknet::ContractAddress;
use starknet::get_caller_address;
use starknet::get_block_timestamp;

#[starknet::contract]
mod PortfolioTracker {
    use super::ContractAddress;
    use super::get_caller_address;
    use super::get_block_timestamp;
    use array::ArrayTrait;
    use zeroable::Zeroable;
    use traits::Into;
    use box::BoxTrait;
    use option::OptionTrait;
    
    #[derive(Drop, Serde, starknet::Store)]
    struct Asset {
        address: ContractAddress,
        amount: u256,
        last_updated: u64,
    }

    #[storage]
    struct Storage {
        user_assets: LegacyMap::<(ContractAddress, ContractAddress), Asset>,
        user_asset_list: LegacyMap::<ContractAddress, Array<ContractAddress>>,
        admin: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin_address: ContractAddress) {
        self.admin.write(admin_address);
    }

    #[external(v0)]
    impl PortfolioTrackerImpl of super::IPortfolioTracker<ContractState> {
        fn add_asset(
            ref self: ContractState, 
            asset_address: ContractAddress, 
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Invalid caller');
            assert(!asset_address.is_zero(), 'Invalid asset address');
            
            let current_time = get_block_timestamp();
            let existing_asset = self.user_assets.read((caller, asset_address));
            
            if existing_asset.address.is_zero() {
                // New asset
                let asset = Asset {
                    address: asset_address,
                    amount: amount,
                    last_updated: current_time,
                };
                
                self.user_assets.write((caller, asset_address), asset);
                
                // Add to user's asset list
                // Note: In a real implementation, you would need to handle array storage differently
                // This is simplified for demonstration
                let mut asset_list = self.user_asset_list.read(caller);
                asset_list.append(asset_address);
                self.user_asset_list.write(caller, asset_list);
            } else {
                // Update existing asset
                let updated_asset = Asset {
                    address: asset_address,
                    amount: existing_asset.amount + amount,
                    last_updated: current_time,
                };
                
                self.user_assets.write((caller, asset_address), updated_asset);
            }
            
            true
        }

        fn remove_asset(
            ref self: ContractState, 
            asset_address: ContractAddress, 
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            let existing_asset = self.user_assets.read((caller, asset_address));
            
            assert(!existing_asset.address.is_zero(), 'Asset not found');
            assert(existing_asset.amount >= amount, 'Insufficient asset amount');
            
            let current_time = get_block_timestamp();
            
            if existing_asset.amount == amount {
                // Remove asset completely
                let zero_asset = Asset {
                    address: contract_address_const::<0>(),
                    amount: 0,
                    last_updated: current_time,
                };
                
                self.user_assets.write((caller, asset_address), zero_asset);
                
                // Remove from user's asset list
                // Note: In a real implementation, you would need to handle array storage differently
                // This is simplified for demonstration
                let mut asset_list = self.user_asset_list.read(caller);
                // Filtering logic would be implemented here
                self.user_asset_list.write(caller, asset_list);
            } else {
                // Update existing asset
                let updated_asset = Asset {
                    address: asset_address,
                    amount: existing_asset.amount - amount,
                    last_updated: current_time,
                };
                
                self.user_assets.write((caller, asset_address), updated_asset);
            }
            
            true
        }

        fn get_portfolio(self: @ContractState, user_address: ContractAddress) -> Array<Asset> {
            let asset_list = self.user_asset_list.read(user_address);
            let mut portfolio = ArrayTrait::new();
            
            // Iterate through asset list and add to portfolio
            // Note: In a real implementation, you would need to handle array iteration differently
            // This is simplified for demonstration
            
            portfolio
        }

        fn get_portfolio_value(self: @ContractState, user_address: ContractAddress) -> u256 {
            let asset_list = self.user_asset_list.read(user_address);
            let mut total_value: u256 = 0;
            
            // Calculate total value
            // Note: In a real implementation, you would need to handle price feeds and calculations
            // This is simplified for demonstration
            
            total_value
        }
    }
}

#[starknet::interface]
trait IPortfolioTracker<TContractState> {
    fn add_asset(ref self: TContractState, asset_address: ContractAddress, amount: u256) -> bool;
    fn remove_asset(ref self: TContractState, asset_address: ContractAddress, amount: u256) -> bool;
    fn get_portfolio(self: @ContractState, user_address: ContractAddress) -> Array<Asset>;
    fn get_portfolio_value(self: @ContractState, user_address: ContractAddress) -> u256;
}

#[derive(Drop, Serde)]
struct Asset {
    address: ContractAddress,
    amount: u256,
    last_updated: u64,
}