#[starknet::contract]
mod TransactionMonitor {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use contracts::src::interfaces::i_transaction_monitor::{ITransactionMonitor, Transaction};

    #[storage]
    struct Storage {
        transactions: LegacyMap<felt252, Transaction>,
        user_transactions: LegacyMap<ContractAddress, Array<felt252>>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        // Initialize contract
    }

    #[external(v0)]
    impl TransactionMonitorImpl of ITransactionMonitor<ContractState> {
        fn register_transaction(
            ref self: ContractState, 
            tx_hash: felt252, 
            tx_type: felt252, 
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            
            // Create transaction record
            let transaction = Transaction {
                tx_hash: tx_hash,
                user: caller,
                tx_type: tx_type,
                amount: amount,
                timestamp: get_block_timestamp(),
                status: 'COMPLETED', // Default status
            };
            
            // Store transaction
            self.transactions.write(tx_hash, transaction);
            
            // Add to user's transaction list
            let mut user_txs = self.user_transactions.read(caller);
            user_txs.append(tx_hash);
            self.user_transactions.write(caller, user_txs);
            
            true
        }

        fn get_transaction_history(self: @ContractState, user_address: ContractAddress) -> Array<Transaction> {
            let tx_hashes = self.user_transactions.read(user_address);
            let mut transactions = ArrayTrait::new();
            
            let mut i: u32 = 0;
            let len = tx_hashes.len();
            
            while i < len {
                let tx_hash = tx_hashes.at(i);
                let transaction = self.transactions.read(*tx_hash);
                transactions.append(transaction);
                i += 1;
            }
            
            transactions
        }

        fn get_transaction_details(self: @ContractState, tx_hash: felt252) -> Transaction {
            self.transactions.read(tx_hash)
        }
    }
}