// StarkPulse ERC20 Token Implementation
// A complete, secure ERC20 token contract with all standard functionality

#[starknet::contract]
mod ERC20Token {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use starknet::storage::Map;
    use zeroable::Zeroable;
    use crate::interfaces::i_erc20::IERC20;

    #[storage]
    struct Storage {
        // Token metadata
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        
        // Balance and allowance mappings
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>,
        
        // Admin controls
        owner: ContractAddress,
        minters: Map<ContractAddress, bool>,
        paused: bool,
        
        // Additional features
        max_supply: u256,
        mintable: bool,
        burnable: bool,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        OwnershipTransferred: OwnershipTransferred,
        MinterAdded: MinterAdded,
        MinterRemoved: MinterRemoved,
        Paused: Paused,
        Unpaused: Unpaused,
        Mint: Mint,
        Burn: Burn,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct MinterAdded {
        minter: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct MinterRemoved {
        minter: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Paused {}

    #[derive(Drop, starknet::Event)]
    struct Unpaused {}

    #[derive(Drop, starknet::Event)]
    struct Mint {
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Burn {
        from: ContractAddress,
        amount: u256,
    }

    // Error constants
    const ERROR_INVALID_RECIPIENT: felt252 = 'ERC20: invalid recipient';
    const ERROR_INVALID_SENDER: felt252 = 'ERC20: invalid sender';
    const ERROR_INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
    const ERROR_INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
    const ERROR_INVALID_SPENDER: felt252 = 'ERC20: invalid spender';
    const ERROR_UNAUTHORIZED: felt252 = 'ERC20: unauthorized';
    const ERROR_PAUSED: felt252 = 'ERC20: token transfer paused';
    const ERROR_EXCEEDS_MAX_SUPPLY: felt252 = 'ERC20: exceeds max supply';
    const ERROR_NOT_MINTABLE: felt252 = 'ERC20: not mintable';
    const ERROR_NOT_BURNABLE: felt252 = 'ERC20: not burnable';
    const ERROR_ZERO_ADDRESS: felt252 = 'ERC20: zero address';

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name_: felt252,
        symbol_: felt252,
        decimals_: u8,
        initial_supply: u256,
        max_supply_: u256,
        owner_: ContractAddress,
        mintable_: bool,
        burnable_: bool
    ) {
        // Validate inputs
        assert(!owner_.is_zero(), ERROR_ZERO_ADDRESS);
        assert(max_supply_ == 0 || initial_supply <= max_supply_, ERROR_EXCEEDS_MAX_SUPPLY);

        // Set token metadata
        self.name.write(name_);
        self.symbol.write(symbol_);
        self.decimals.write(decimals_);
        self.total_supply.write(initial_supply);
        self.max_supply.write(max_supply_);
        
        // Set owner and permissions
        self.owner.write(owner_);
        self.mintable.write(mintable_);
        self.burnable.write(burnable_);
        self.paused.write(false);
        
        // Mint initial supply to owner
        if initial_supply > 0 {
            self.balances.write(owner_, initial_supply);
            
            // Emit transfer event from zero address
            self.emit(Transfer {
                from: ContractAddress::zero(),
                to: owner_,
                value: initial_supply,
            });
        }
        
        // Add owner as initial minter if mintable
        if mintable_ {
            self.minters.write(owner_, true);
            self.emit(MinterAdded { minter: owner_ });
        }
    }

    #[abi(embed_v0)]
    impl ERC20Impl of IERC20<ContractState> {
        // Standard ERC20 functions
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            
            // Check allowance if caller is not the sender
            if caller != sender {
                let current_allowance = self.allowances.read((sender, caller));
                assert(current_allowance >= amount, ERROR_INSUFFICIENT_ALLOWANCE);
                
                // Update allowance
                self.allowances.write((sender, caller), current_allowance - amount);
            }
            
            self._transfer(sender, recipient, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let owner = get_caller_address();
            self._approve(owner, spender, amount);
            true
        }

        // CamelCase variants for compatibility
        fn totalSupply(self: @ContractState) -> u256 {
            self.total_supply()
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self.balance_of(account)
        }

        fn transferFrom(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u256
        ) -> bool {
            self.transfer_from(sender, recipient, amount)
        }
    }

    // Additional functions for enhanced functionality
    #[abi(embed_v0)]
    impl ERC20ExtendedImpl of IERC20Extended<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            self._assert_only_minter();
            self._assert_not_paused();
            assert(self.mintable.read(), ERROR_NOT_MINTABLE);
            assert(!to.is_zero(), ERROR_INVALID_RECIPIENT);
            assert(amount > 0, 'ERC20: amount must be positive');
            
            // Check max supply if set
            let max_supply = self.max_supply.read();
            if max_supply > 0 {
                let new_total_supply = self.total_supply.read() + amount;
                assert(new_total_supply <= max_supply, ERROR_EXCEEDS_MAX_SUPPLY);
            }
            
            // Update balances and total supply
            let current_balance = self.balances.read(to);
            self.balances.write(to, current_balance + amount);
            
            let current_total_supply = self.total_supply.read();
            self.total_supply.write(current_total_supply + amount);
            
            // Emit events
            self.emit(Transfer {
                from: ContractAddress::zero(),
                to: to,
                value: amount,
            });
            
            self.emit(Mint {
                to: to,
                amount: amount,
            });
            
            true
        }

        fn burn(ref self: ContractState, amount: u256) -> bool {
            let caller = get_caller_address();
            self._burn(caller, amount);
            true
        }

        fn burn_from(ref self: ContractState, from: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            
            // Check allowance if caller is not the owner
            if caller != from {
                let current_allowance = self.allowances.read((from, caller));
                assert(current_allowance >= amount, ERROR_INSUFFICIENT_ALLOWANCE);
                
                // Update allowance
                self.allowances.write((from, caller), current_allowance - amount);
            }
            
            self._burn(from, amount);
            true
        }

        fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256) -> bool {
            let owner = get_caller_address();
            let current_allowance = self.allowances.read((owner, spender));
            self._approve(owner, spender, current_allowance + added_value);
            true
        }

        fn decrease_allowance(ref self: ContractState, spender: ContractAddress, subtracted_value: u256) -> bool {
            let owner = get_caller_address();
            let current_allowance = self.allowances.read((owner, spender));
            assert(current_allowance >= subtracted_value, ERROR_INSUFFICIENT_ALLOWANCE);
            self._approve(owner, spender, current_allowance - subtracted_value);
            true
        }

        // Admin functions
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) -> bool {
            self._assert_only_owner();
            assert(!new_owner.is_zero(), ERROR_ZERO_ADDRESS);
            
            let old_owner = self.owner.read();
            self.owner.write(new_owner);
            
            self.emit(OwnershipTransferred {
                previous_owner: old_owner,
                new_owner: new_owner,
            });
            
            true
        }

        fn add_minter(ref self: ContractState, minter: ContractAddress) -> bool {
            self._assert_only_owner();
            assert(!minter.is_zero(), ERROR_ZERO_ADDRESS);
            
            self.minters.write(minter, true);
            
            self.emit(MinterAdded { minter: minter });
            
            true
        }

        fn remove_minter(ref self: ContractState, minter: ContractAddress) -> bool {
            self._assert_only_owner();
            
            self.minters.write(minter, false);
            
            self.emit(MinterRemoved { minter: minter });
            
            true
        }

        fn pause(ref self: ContractState) -> bool {
            self._assert_only_owner();
            assert(!self.paused.read(), 'ERC20: already paused');
            
            self.paused.write(true);
            
            self.emit(Paused {});
            
            true
        }

        fn unpause(ref self: ContractState) -> bool {
            self._assert_only_owner();
            assert(self.paused.read(), 'ERC20: not paused');
            
            self.paused.write(false);
            
            self.emit(Unpaused {});
            
            true
        }

        // View functions
        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn is_minter(self: @ContractState, account: ContractAddress) -> bool {
            self.minters.read(account)
        }

        fn is_paused(self: @ContractState) -> bool {
            self.paused.read()
        }

        fn max_supply(self: @ContractState) -> u256 {
            self.max_supply.read()
        }

        fn is_mintable(self: @ContractState) -> bool {
            self.mintable.read()
        }

        fn is_burnable(self: @ContractState) -> bool {
            self.burnable.read()
        }
    }

    // Internal functions
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) {
            self._assert_not_paused();
            assert(!sender.is_zero(), ERROR_INVALID_SENDER);
            assert(!recipient.is_zero(), ERROR_INVALID_RECIPIENT);
            
            let sender_balance = self.balances.read(sender);
            assert(sender_balance >= amount, ERROR_INSUFFICIENT_BALANCE);
            
            // Update balances
            self.balances.write(sender, sender_balance - amount);
            
            let recipient_balance = self.balances.read(recipient);
            self.balances.write(recipient, recipient_balance + amount);
            
            // Emit transfer event
            self.emit(Transfer {
                from: sender,
                to: recipient,
                value: amount,
            });
        }

        fn _approve(ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256) {
            assert(!owner.is_zero(), ERROR_INVALID_SENDER);
            assert(!spender.is_zero(), ERROR_INVALID_SPENDER);
            
            self.allowances.write((owner, spender), amount);
            
            self.emit(Approval {
                owner: owner,
                spender: spender,
                value: amount,
            });
        }

        fn _burn(ref self: ContractState, from: ContractAddress, amount: u256) {
            self._assert_not_paused();
            assert(self.burnable.read(), ERROR_NOT_BURNABLE);
            assert(!from.is_zero(), ERROR_INVALID_SENDER);
            assert(amount > 0, 'ERC20: amount must be positive');
            
            let account_balance = self.balances.read(from);
            assert(account_balance >= amount, ERROR_INSUFFICIENT_BALANCE);
            
            // Update balances and total supply
            self.balances.write(from, account_balance - amount);
            
            let current_total_supply = self.total_supply.read();
            self.total_supply.write(current_total_supply - amount);
            
            // Emit events
            self.emit(Transfer {
                from: from,
                to: ContractAddress::zero(),
                value: amount,
            });
            
            self.emit(Burn {
                from: from,
                amount: amount,
            });
        }

        fn _assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, ERROR_UNAUTHORIZED);
        }

        fn _assert_only_minter(self: @ContractState) {
            let caller = get_caller_address();
            assert(self.minters.read(caller), ERROR_UNAUTHORIZED);
        }

        fn _assert_not_paused(self: @ContractState) {
            assert(!self.paused.read(), ERROR_PAUSED);
        }
    }
}

// Extended interface for additional functionality
#[starknet::interface]
trait IERC20Extended<TContractState> {
    // Minting and burning
    fn mint(ref self: TContractState, to: starknet::ContractAddress, amount: u256) -> bool;
    fn burn(ref self: TContractState, amount: u256) -> bool;
    fn burn_from(ref self: TContractState, from: starknet::ContractAddress, amount: u256) -> bool;
    
    // Enhanced allowance functions
    fn increase_allowance(ref self: TContractState, spender: starknet::ContractAddress, added_value: u256) -> bool;
    fn decrease_allowance(ref self: TContractState, spender: starknet::ContractAddress, subtracted_value: u256) -> bool;
    
    // Admin functions
    fn transfer_ownership(ref self: TContractState, new_owner: starknet::ContractAddress) -> bool;
    fn add_minter(ref self: TContractState, minter: starknet::ContractAddress) -> bool;
    fn remove_minter(ref self: TContractState, minter: starknet::ContractAddress) -> bool;
    fn pause(ref self: TContractState) -> bool;
    fn unpause(ref self: TContractState) -> bool;
    
    // View functions
    fn owner(self: @TContractState) -> starknet::ContractAddress;
    fn is_minter(self: @TContractState, account: starknet::ContractAddress) -> bool;
    fn is_paused(self: @TContractState) -> bool;
    fn max_supply(self: @TContractState) -> u256;
    fn is_mintable(self: @TContractState) -> bool;
    fn is_burnable(self: @TContractState) -> bool;
}
