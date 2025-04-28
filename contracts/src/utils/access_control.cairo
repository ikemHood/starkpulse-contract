#[starknet::contract]
mod AccessControl {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::Map;
    #[storage]
    struct Storage {
        roles: Map<(felt252, ContractAddress), bool>,
        role_admins: Map<felt252, felt252>,
        admin: ContractAddress,
    }

    // Role constants
    const ADMIN_ROLE: felt252 = 'ADMIN_ROLE';
    const PORTFOLIO_MANAGER_ROLE: felt252 = 'PORTFOLIO_MANAGER_ROLE';
    const TRANSACTION_MONITOR_ROLE: felt252 = 'TRANSACTION_MONITOR_ROLE';

    #[constructor]
    fn constructor(ref self: ContractState, admin_address: ContractAddress) {
        self.admin.write(admin_address);
        
        // Set up role hierarchy
        self.roles.write((ADMIN_ROLE, admin_address), true);
        self.role_admins.write(PORTFOLIO_MANAGER_ROLE, ADMIN_ROLE);
        self.role_admins.write(TRANSACTION_MONITOR_ROLE, ADMIN_ROLE);
    }

    #[external(v0)]
    fn has_role(self: @ContractState, role: felt252, account: ContractAddress) -> bool {
        self.roles.read((role, account))
    }

    #[external(v0)]
    fn grant_role(ref self: ContractState, role: felt252, account: ContractAddress) -> bool {
        let caller = get_caller_address();
        
        // Check if caller has admin role for the role being granted
        let admin_role = self.role_admins.read(role);
        assert(self.roles.read((admin_role, caller)), 'Not authorized');
        
        self.roles.write((role, account), true);
        
        true
    }

    #[external(v0)]
    fn revoke_role(ref self: ContractState, role: felt252, account: ContractAddress) -> bool {
        let caller = get_caller_address();
        
        // Check if caller has admin role for the role being revoked
        let admin_role = self.role_admins.read(role);
        assert(self.roles.read((admin_role, caller)), 'Not authorized');
        
        self.roles.write((role, account), false);
        
        true
    }

    #[external(v0)]
    fn renounce_role(ref self: ContractState, role: felt252) -> bool {
        let caller = get_caller_address();
        
        // Account can renounce their own role
        self.roles.write((role, caller), false);
        
        true
    }

    #[external(v0)]
    fn set_role_admin(ref self: ContractState, role: felt252, admin_role: felt252) -> bool {
        let caller = get_caller_address();
        
        // Only admin can set role admins
        assert(caller == self.admin.read(), 'Not authorized');
        
        self.role_admins.write(role, admin_role);
        
        true
    }
}