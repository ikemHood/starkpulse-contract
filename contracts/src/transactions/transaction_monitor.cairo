#[starknet::contract]
mod TransactionMonitor {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::Map;
    use zeroable::Zeroable;
    use array::ArrayTrait;
    use contracts::src::interfaces::i_transaction_monitor::{ITransactionMonitor, Transaction};
    use contracts::src::utils::access_control::{AccessControl, IAccessControl};

    // Constants for transaction status
    const STATUS_PENDING: felt252 = 'PENDING';
    const STATUS_COMPLETED: felt252 = 'COMPLETED';
    const STATUS_FAILED: felt252 = 'FAILED';
    const STATUS_CANCELLED: felt252 = 'CANCELLED';

    // Constants for transaction types
    const TYPE_DEPOSIT: felt252 = 'DEPOSIT';
    const TYPE_WITHDRAWAL: felt252 = 'WITHDRAWAL';
    const TYPE_SWAP: felt252 = 'SWAP';
    const TYPE_TRANSFER: felt252 = 'TRANSFER';
    const TYPE_OTHER: felt252 = 'OTHER';

    // Constants for notification types
    const NOTIFY_ALL: felt252 = 'ALL';
    const NOTIFY_DEPOSITS: felt252 = 'DEPOSITS';
    const NOTIFY_WITHDRAWALS: felt252 = 'WITHDRAWALS';
    const NOTIFY_STATUS_CHANGES: felt252 = 'STATUS_CHANGES';

    #[storage]
    struct Storage {
        // Transaction storage
        transactions: Map<felt252, Transaction>,
        user_transactions: Map<ContractAddress, Array<felt252>>,
        transaction_count: u64,
        // Notification preferences
        user_notification_preferences: Map<(ContractAddress, felt252), bool>,
        // Access control
        access_control: IAccessControl,
        // Admin address
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TransactionRecorded: TransactionRecorded,
        TransactionStatusUpdated: TransactionStatusUpdated,
        NotificationPreferencesSet: NotificationPreferencesSet,
    }

    #[derive(Drop, starknet::Event)]
    struct TransactionRecorded {
        tx_hash: felt252,
        user: ContractAddress,
        tx_type: felt252,
        amount: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct TransactionStatusUpdated {
        tx_hash: felt252,
        old_status: felt252,
        new_status: felt252,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct NotificationPreferencesSet {
        user: ContractAddress,
        notification_type: felt252,
        enabled: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin_address: ContractAddress) {
        // Initialize contract
        self.admin.write(admin_address);
        self.transaction_count.write(0);

        // Set default notification preferences (all enabled)
        let caller = get_caller_address();
        self.user_notification_preferences.write((caller, NOTIFY_ALL), true);
        self.user_notification_preferences.write((caller, NOTIFY_DEPOSITS), true);
        self.user_notification_preferences.write((caller, NOTIFY_WITHDRAWALS), true);
        self.user_notification_preferences.write((caller, NOTIFY_STATUS_CHANGES), true);
    }

    #[external(v0)]
    impl TransactionMonitorImpl of ITransactionMonitor<ContractState> {
        fn record_transaction(
            ref self: ContractState,
            tx_hash: felt252,
            tx_type: felt252,
            amount: u256,
            description: felt252,
        ) -> bool {
            let caller = get_caller_address();

            // Validate transaction hash is not empty
            assert(tx_hash != 0, "Invalid transaction hash");

            // Validate transaction type
            assert(
                tx_type == TYPE_DEPOSIT
                    || tx_type == TYPE_WITHDRAWAL
                    || tx_type == TYPE_SWAP
                    || tx_type == TYPE_TRANSFER
                    || tx_type == TYPE_OTHER,
                "Invalid transaction type",
            );

            // Validate amount is not zero
            assert(amount != 0, "Amount cannot be zero");

            // Check if transaction already exists
            let existing_tx = self.transactions.read(tx_hash);
            assert(existing_tx.tx_hash == 0, "Transaction already exists");

            // Create transaction record
            let transaction = Transaction {
                tx_hash: tx_hash,
                user: caller,
                tx_type: tx_type,
                amount: amount,
                timestamp: get_block_timestamp(),
                status: STATUS_PENDING,
                description: description,
            };

            // Store transaction
            self.transactions.write(tx_hash, transaction);

            // Add to user's transaction list
            let mut user_txs = self.user_transactions.read(caller);
            user_txs.append(tx_hash);
            self.user_transactions.write(caller, user_txs);

            // Increment transaction count
            let current_count = self.transaction_count.read();
            self.transaction_count.write(current_count + 1);

            // Emit event
            self
                .emit(
                    TransactionRecorded {
                        tx_hash: tx_hash,
                        user: caller,
                        tx_type: tx_type,
                        amount: amount,
                        timestamp: get_block_timestamp(),
                    },
                );

            true
        }

        fn update_transaction_status(
            ref self: ContractState, tx_hash: felt252, new_status: felt252,
        ) -> bool {
            // Validate transaction hash
            assert(tx_hash != 0, "Invalid transaction hash");

            // Validate status
            assert(
                new_status == STATUS_PENDING
                    || new_status == STATUS_COMPLETED
                    || new_status == STATUS_FAILED
                    || new_status == STATUS_CANCELLED,
                "Invalid status",
            );

            // Get transaction
            let mut transaction = self.transactions.read(tx_hash);
            assert(transaction.tx_hash != 0, "Transaction does not exist");

            // Check if caller is the transaction owner or admin
            let caller = get_caller_address();
            assert(
                caller == transaction.user || caller == self.admin.read(),
                "Not authorized to update status",
            );

            // Store old status for event
            let old_status = transaction.status;

            // Update status
            transaction.status = new_status;
            self.transactions.write(tx_hash, transaction);

            // Emit event
            self
                .emit(
                    TransactionStatusUpdated {
                        tx_hash: tx_hash,
                        old_status: old_status,
                        new_status: new_status,
                        timestamp: get_block_timestamp(),
                    },
                );

            true
        }

        fn set_notification_preferences(
            ref self: ContractState, notification_types: Array<felt252>, enabled: bool,
        ) -> bool {
            let caller = get_caller_address();

            // Validate notification types and set preferences
            let mut i: u32 = 0;
            let len = notification_types.len();

            while i < len {
                let notification_type = *notification_types.at(i);

                // Validate notification type
                assert(
                    notification_type == NOTIFY_ALL
                        || notification_type == NOTIFY_DEPOSITS
                        || notification_type == NOTIFY_WITHDRAWALS
                        || notification_type == NOTIFY_STATUS_CHANGES,
                    "Invalid notification type",
                );

                // Set preference
                self.user_notification_preferences.write((caller, notification_type), enabled);

                // Emit event
                self
                    .emit(
                        NotificationPreferencesSet {
                            user: caller, notification_type: notification_type, enabled: enabled,
                        },
                    );

                i += 1;
            }

            true
        }

        fn get_notification_preferences(
            self: @ContractState, user_address: ContractAddress,
        ) -> Array<felt252> {
            let mut enabled_preferences = ArrayTrait::new();

            // Check each notification type
            if self.user_notification_preferences.read((user_address, NOTIFY_ALL)) {
                enabled_preferences.append(NOTIFY_ALL);
            }

            if self.user_notification_preferences.read((user_address, NOTIFY_DEPOSITS)) {
                enabled_preferences.append(NOTIFY_DEPOSITS);
            }

            if self.user_notification_preferences.read((user_address, NOTIFY_WITHDRAWALS)) {
                enabled_preferences.append(NOTIFY_WITHDRAWALS);
            }

            if self.user_notification_preferences.read((user_address, NOTIFY_STATUS_CHANGES)) {
                enabled_preferences.append(NOTIFY_STATUS_CHANGES);
            }

            enabled_preferences
        }

        fn get_transaction_history(
            self: @ContractState,
            user_address: ContractAddress,
            page: u32,
            page_size: u32,
            filter_type: felt252,
            filter_status: felt252,
        ) -> Array<Transaction> {
            let tx_hashes = self.user_transactions.read(user_address);
            let mut transactions = ArrayTrait::new();

            // Calculate pagination
            let total_txs = tx_hashes.len();
            let start_idx = if page * page_size < total_txs {
                page * page_size
            } else {
                0
            };
            let end_idx = if (page + 1) * page_size < total_txs {
                (page + 1) * page_size
            } else {
                total_txs
            };

            let mut i = start_idx;

            while i < end_idx {
                let tx_hash = tx_hashes.at(i);
                let transaction = self.transactions.read(*tx_hash);

                // Apply filters if specified
                let type_match = filter_type == 0 || transaction.tx_type == filter_type;
                let status_match = filter_status == 0 || transaction.status == filter_status;

                if type_match && status_match {
                    transactions.append(transaction);
                }

                i += 1;
            }

            transactions
        }

        fn get_transaction_details(self: @ContractState, tx_hash: felt252) -> Transaction {
            // Validate transaction hash
            assert(tx_hash != 0, "Invalid transaction hash");

            // Get transaction
            let transaction = self.transactions.read(tx_hash);
            assert(transaction.tx_hash != 0, "Transaction does not exist");

            transaction
        }
    }

    #[generate_trait]
    impl HelperImpl of HelperTrait {
        fn assert_only_admin(ref self: ContractState) {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, "Caller is not admin");
        }
    }
}
