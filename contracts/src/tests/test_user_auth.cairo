#[cfg(test)]
mod test_user_auth {
    use starknet::{
        ContractAddress, 
        contract_address_const, 
        get_caller_address, 
        get_block_timestamp,
        testing::set_caller_address,
        testing::set_block_timestamp
    };
    
    // Import modules
    use crate::auth::user_auth::UserAuth;
    use crate::interfaces::i_user_auth::{UserProfile, Session};
    
    // Test addresses
    const ADMIN: felt252 = 0x123;
    const USER1: felt252 = 0x456;
    const USER2: felt252 = 0x789;
    
    // Test data
    const USERNAME1: felt252 = 'user1';
    const DISPLAY_NAME1: felt252 = 'User One';
    const EMAIL_HASH1: felt252 = 0x111;
    
    const USERNAME2: felt252 = 'user2';
    const DISPLAY_NAME2: felt252 = 'User Two';
    const EMAIL_HASH2: felt252 = 0x222;
    
    #[test]
    #[available_gas(2000000)]
    fn test_user_registration() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Test user registration
        set_caller_address(user1);
        let result = contract.register_user(USERNAME1, DISPLAY_NAME1, EMAIL_HASH1);
        assert(result, "Registration failed");
        
        // Verify user profile
        let profile = contract.get_user_profile(user1);
        assert(profile.username == USERNAME1, "Username mismatch");
        assert(profile.display_name == DISPLAY_NAME1, "Display name mismatch");
        
        // Verify username lookup
        let address = contract.get_user_by_username(USERNAME1);
        assert(address == user1, "Username lookup failed");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_login_logout() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Register user
        set_caller_address(user1);
        contract.register_user(USERNAME1, DISPLAY_NAME1, EMAIL_HASH1);
        
        // Test login
        let mut signature = array![];
        signature.append(0x123);
        let message_hash = 0x456;
        let nonce = 0;
        
        let session_id = contract.login(signature, message_hash, nonce);
        assert(session_id != 0, "Login failed");
        
        // Verify session
        let is_valid = contract.validate_session(user1);
        assert(is_valid, "Session validation failed");
        
        // Test logout
        let result = contract.logout();
        assert(result, "Logout failed");
        
        // Verify session is no longer valid
        let is_valid_after_logout = contract.validate_session(user1);
        assert(!is_valid_after_logout, "Session still valid after logout");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_profile_management() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Register user
        set_caller_address(user1);
        contract.register_user(USERNAME1, DISPLAY_NAME1, EMAIL_HASH1);
        
        // Login
        let mut signature = array![];
        signature.append(0x123);
        let message_hash = 0x456;
        let nonce = 0;
        contract.login(signature, message_hash, nonce);
        
        // Test profile update
        let new_display_name = 'Updated User';
        let new_email_hash = 0x333;
        let result = contract.update_profile(new_display_name, new_email_hash);
        assert(result, "Profile update failed");
        
        // Verify profile changes
        let updated_profile = contract.get_user_profile(user1);
        assert(updated_profile.display_name == new_display_name, "Display name not updated");
        assert(updated_profile.email_hash == new_email_hash, "Email hash not updated");
        
        // Test username change
        let new_username = 'new_user1';
        let result = contract.change_username(new_username);
        assert(result, "Username change failed");
        
        // Verify username change
        let updated_profile = contract.get_user_profile(user1);
        assert(updated_profile.username == new_username, "Username not updated");
        
        // Verify old username is no longer valid
        let old_username_lookup = contract.get_user_by_username(USERNAME1);
        assert(old_username_lookup.is_zero(), "Old username still mapped");
        
        // Verify new username lookup
        let new_username_lookup = contract.get_user_by_username(new_username);
        assert(new_username_lookup == user1, "New username lookup failed");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_admin_functions() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Verify admin
        let is_admin = contract.is_admin(admin);
        assert(is_admin, "Admin check failed");
        
        // Transfer admin rights
        let result = contract.transfer_admin(user1);
        assert(result, "Admin transfer failed");
        
        // Verify new admin
        let is_new_admin = contract.is_admin(user1);
        assert(is_new_admin, "New admin check failed");
        
        // Verify old admin is no longer admin
        let is_old_admin = contract.is_admin(admin);
        assert(!is_old_admin, "Old admin still has admin rights");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_account_recovery() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        let user2 = contract_address_const::<USER2>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Register users
        set_caller_address(user1);
        contract.register_user(USERNAME1, DISPLAY_NAME1, EMAIL_HASH1);
        
        set_caller_address(user2);
        contract.register_user(USERNAME2, DISPLAY_NAME2, EMAIL_HASH2);
        
        // Login user1
        set_caller_address(user1);
        let mut signature = array![];
        signature.append(0x123);
        let message_hash = 0x456;
        let nonce = 0;
        contract.login(signature, message_hash, nonce);
        
        // Set recovery address
        let result = contract.set_recovery_address(user2);
        assert(result, "Setting recovery address failed");
        
        // Logout user1
        contract.logout();
        
        // Recover account
        set_caller_address(user2);
        let recovery_result = contract.recover_account(user1);
        assert(recovery_result, "Account recovery failed");
        
        // Verify user1 now has an active session
        let is_valid = contract.validate_session(user1);
        assert(is_valid, "Session not valid after recovery");
    }
    
    #[test]
    #[available_gas(2000000)]
    fn test_session_expiration() {
        // Setup
        let admin = contract_address_const::<ADMIN>();
        let user1 = contract_address_const::<USER1>();
        
        set_caller_address(admin);
        let mut contract = UserAuth::unsafe_new();
        
        // Register user
        set_caller_address(user1);
        contract.register_user(USERNAME1, DISPLAY_NAME1, EMAIL_HASH1);
        
        // Set initial timestamp
        set_block_timestamp(1000);
        
        // Login
        let mut signature = array![];
        signature.append(0x123);
        let message_hash = 0x456;
        let nonce = 0;
        contract.login(signature, message_hash, nonce);
        
        // Verify session is valid
        let is_valid = contract.validate_session(user1);
        assert(is_valid, "Session should be valid");
        
        // Advance time beyond session expiration (24 hours + 1 second)
        set_block_timestamp(1000 + 86400 + 1);
        
        // Verify session is no longer valid
        let is_valid_after_expiration = contract.validate_session(user1);
        assert(!is_valid_after_expiration, "Session should be expired");
    }
}