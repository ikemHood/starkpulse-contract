#[cfg(test)]
mod test_contract_interaction {
    use starknet::{ContractAddress, contract_address_const, get_caller_address};
    use starknet::testing::set_caller_address;
    
    use crate::utils::contract_interaction::ContractInteraction;
    use crate::interfaces::i_contract_interaction::IContractInteraction;
    
    // Test addresses
    const ADMIN: felt252 = 0x123;
    const USER1: felt252 = 0x456;
    const CONTRACT1: felt252 = 0x789;
    const CONTRACT_NAME: felt252 = 'TEST_CONTRACT';
    
    #[test]
    #[available_gas(2000000)]
    fn test_contract_registration() {
        let admin = contract_address_const::<ADMIN>();
        let contract_address = contract_address_const::<CONTRACT1>();
        
        set_caller_address(admin);
        
        let mut contract = ContractInteraction::unsafe_new();
        contract.register_contract(CONTRACT_NAME, contract_address);
        
        let retrieved_address = contract.get_contract_address(CONTRACT_NAME);
        assert(retrieved_address == contract_address, "Address mismatch");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_caller_approval() {
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        let contract_address = contract_address_const::<CONTRACT1>();
        
        set_caller_address(admin);
        
        let mut contract = ContractInteraction::unsafe_new();
        contract.register_contract(CONTRACT_NAME, contract_address);
        contract.approve_caller(CONTRACT_NAME, user1);
        
        // Test calling contract (simulated)
        set_caller_address(user1);
        // Would normally call contract here
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_contract_calling() {
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        let contract_address = contract_address_const::<CONTRACT1>();
        
        set_caller_address(admin);
        
        let mut contract = ContractInteraction::unsafe_new();
        contract.register_contract(CONTRACT_NAME, contract_address);
        contract.approve_caller(CONTRACT_NAME, user1);
        
        set_caller_address(user1);
        
        // This would fail if caller wasn't approved
        let _ = contract.call_contract(CONTRACT_NAME, 'test_function', array![]);
    }
}