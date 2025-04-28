#[starknet::interface]
trait ITokenVestingContract<TContractState> {
    // Administrative functions
    fn create_vesting_schedule(
        ref self: TContractState,
        beneficiary: starknet::ContractAddress,
        amount: u256,
        start_time: u64,
        duration: u64,
        cliff_duration: u64
    ) -> u64;
    
    fn revoke_schedule(
        ref self: TContractState, 
        beneficiary: starknet::ContractAddress, 
        schedule_id: u64
    );
    
    fn emergency_pause(ref self: TContractState);
    fn emergency_unpause(ref self: TContractState);
    fn change_admin(ref self: TContractState, new_admin: starknet::ContractAddress);
    
    // User functions
    fn release_tokens(ref self: TContractState, schedule_id: u64);
    
    // View functions
    fn get_token_address(self: @TContractState) -> starknet::ContractAddress;
    fn get_admin(self: @TContractState) -> starknet::ContractAddress;
    fn is_paused(self: @TContractState) -> bool;
    fn get_vesting_schedule(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress, 
        schedule_id: u64
    ) -> TokenVestingTypes::VestingSchedule;
    fn get_schedule_count(self: @TContractState) -> u64;
    fn get_beneficiary_schedule_count(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress
    ) -> u64;
    fn get_total_vesting_for_beneficiary(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress
    ) -> u256;
    fn is_schedule_revoked(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress, 
        schedule_id: u64
    ) -> bool;
    fn calculate_vested_amount(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress, 
        schedule_id: u64
    ) -> u256;
    fn calculate_releasable_amount(
        self: @TContractState, 
        beneficiary: starknet::ContractAddress, 
        schedule_id: u64
    ) -> u256;
}

// Shared types for token vesting
pub mod TokenVestingTypes {
    use starknet::ContractAddress;
    
    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct VestingSchedule {
        pub beneficiary: ContractAddress,
        pub start_time: u64,
        pub duration: u64,
        pub total_amount: u256,
        pub released_amount: u256,
        pub cliff_duration: u64,
        pub schedule_id: u64,
    }
} 