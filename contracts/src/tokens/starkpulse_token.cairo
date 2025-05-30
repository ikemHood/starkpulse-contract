// StarkPulse Native Token Implementation
// The official token of the StarkPulse ecosystem

#[starknet::contract]
mod StarkPulseToken {
    use starknet::{ContractAddress, get_caller_address};
    use crate::tokens::erc20_token::{ERC20Token, IERC20Extended};
    use crate::interfaces::i_erc20::IERC20;

    #[storage]
    struct Storage {
        erc20: ERC20Token::ContractState,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // Initialize with StarkPulse token parameters
        self.erc20.constructor(
            'StarkPulse Token',     // name
            'SPT',                  // symbol
            18,                     // decimals
            100000000000000000000000000, // initial_supply: 100M tokens
            1000000000000000000000000000, // max_supply: 1B tokens
            owner,                  // owner
            true,                   // mintable
            true                    // burnable
        );
    }

    #[abi(embed_v0)]
    impl ERC20Impl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.erc20.name()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.erc20.symbol()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.erc20.decimals()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.erc20.total_supply()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc20.balance_of(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.erc20.allowance(owner, spender)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            self.erc20.transfer(recipient, amount)
        }

        fn transfer_from(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u256
        ) -> bool {
            self.erc20.transfer_from(sender, recipient, amount)
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            self.erc20.approve(spender, amount)
        }

        fn totalSupply(self: @ContractState) -> u256 {
            self.erc20.totalSupply()
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self.erc20.balanceOf(account)
        }

        fn transferFrom(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u256
        ) -> bool {
            self.erc20.transferFrom(sender, recipient, amount)
        }
    }

    #[abi(embed_v0)]
    impl ERC20ExtendedImpl of IERC20Extended<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            self.erc20.mint(to, amount)
        }

        fn burn(ref self: ContractState, amount: u256) -> bool {
            self.erc20.burn(amount)
        }

        fn burn_from(ref self: ContractState, from: ContractAddress, amount: u256) -> bool {
            self.erc20.burn_from(from, amount)
        }

        fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256) -> bool {
            self.erc20.increase_allowance(spender, added_value)
        }

        fn decrease_allowance(ref self: ContractState, spender: ContractAddress, subtracted_value: u256) -> bool {
            self.erc20.decrease_allowance(spender, subtracted_value)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) -> bool {
            self.erc20.transfer_ownership(new_owner)
        }

        fn add_minter(ref self: ContractState, minter: ContractAddress) -> bool {
            self.erc20.add_minter(minter)
        }

        fn remove_minter(ref self: ContractState, minter: ContractAddress) -> bool {
            self.erc20.remove_minter(minter)
        }

        fn pause(ref self: ContractState) -> bool {
            self.erc20.pause()
        }

        fn unpause(ref self: ContractState) -> bool {
            self.erc20.unpause()
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self.erc20.owner()
        }

        fn is_minter(self: @ContractState, account: ContractAddress) -> bool {
            self.erc20.is_minter(account)
        }

        fn is_paused(self: @ContractState) -> bool {
            self.erc20.is_paused()
        }

        fn max_supply(self: @ContractState) -> u256 {
            self.erc20.max_supply()
        }

        fn is_mintable(self: @ContractState) -> bool {
            self.erc20.is_mintable()
        }

        fn is_burnable(self: @ContractState) -> bool {
            self.erc20.is_burnable()
        }
    }
}
