#[contract]
mod StarkPulse {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::get_block_timestamp;
    use array::ArrayTrait;
    use option::OptionTrait;
    use traits::Into;
    use traits::TryInto;
    use zeroable::Zeroable;

    // Storage variables
    struct Storage {
        owner: ContractAddress,
        news_count: u256,
        news_items: LegacyMap<u256, NewsItem>,
        user_profiles: LegacyMap<ContractAddress, UserProfile>,
        user_favorites: LegacyMap<(ContractAddress, u256), bool>,
    }

    // Structs
    #[derive(Drop, Serde)]
    struct NewsItem {
        id: u256,
        title: felt252,
        content: felt252,
        timestamp: u64,
        author: ContractAddress,
        category: felt252,
        likes: u256,
    }

    #[derive(Drop, Serde)]
    struct UserProfile {
        address: ContractAddress,
        username: felt252,
        registered_at: u64,
        news_posted: u256,
    }

    // Events
    #[event]
    fn NewsItemAdded(id: u256, title: felt252, author: ContractAddress) {}

    #[event]
    fn NewsItemLiked(id: u256, user: ContractAddress) {}

    #[event]
    fn UserRegistered(user: ContractAddress, username: felt252) {}

    // Constructor
    #[constructor]
    fn constructor() {
        let caller = get_caller_address();
        owner::write(caller);
        news_count::write(0);
    }

    // External functions
    #[external]
    fn register_user(username: felt252) {
        let caller = get_caller_address();
        
        // Check if user is already registered
        let existing_profile = user_profiles::read(caller);
        assert(existing_profile.address.is_zero(), 'User already registered');
        
        // Create new user profile
        let timestamp = get_block_timestamp();
        let new_profile = UserProfile {
            address: caller,
            username: username,
            registered_at: timestamp,
            news_posted: 0,
        };
        
        user_profiles::write(caller, new_profile);
        
        // Emit event
        UserRegistered(caller, username);
    }

    #[external]
    fn add_news_item(title: felt252, content: felt252, category: felt252) {
        let caller = get_caller_address();
        
        // Check if user is registered
        let user_profile = user_profiles::read(caller);
        assert(!user_profile.address.is_zero(), 'User not registered');
        
        // Increment news count
        let current_count = news_count::read();
        let new_count = current_count + 1;
        news_count::write(new_count);
        
        // Create news item
        let timestamp = get_block_timestamp();
        let news_item = NewsItem {
            id: new_count,
            title: title,
            content: content,
            timestamp: timestamp,
            author: caller,
            category: category,
            likes: 0,
        };
        
        // Store news item
        news_items::write(new_count, news_item);
        
        // Update user profile
        let updated_profile = UserProfile {
            address: user_profile.address,
            username: user_profile.username,
            registered_at: user_profile.registered_at,
            news_posted: user_profile.news_posted + 1,
        };
        user_profiles::write(caller, updated_profile);
        
        // Emit event
        NewsItemAdded(new_count, title, caller);
    }

    #[external]
    fn like_news_item(news_id: u256) {
        let caller = get_caller_address();
        
        // Check if user is registered
        let user_profile = user_profiles::read(caller);
        assert(!user_profile.address.is_zero(), 'User not registered');
        
        // Check if news item exists
        let news_item = news_items::read(news_id);
        assert(news_item.id == news_id, 'News item does not exist');
        
        // Check if user has already liked this news item
        let has_liked = user_favorites::read((caller, news_id));
        assert(!has_liked, 'Already liked this news item');
        
        // Update like count
        let updated_news_item = NewsItem {
            id: news_item.id,
            title: news_item.title,
            content: news_item.content,
            timestamp: news_item.timestamp,
            author: news_item.author,
            category: news_item.category,
            likes: news_item.likes + 1,
        };
        news_items::write(news_id, updated_news_item);
        
        // Mark as liked by user
        user_favorites::write((caller, news_id), true);
        
        // Emit event
        NewsItemLiked(news_id, caller);
    }

    // View functions
    #[view]
    fn get_news_item(news_id: u256) -> NewsItem {
        news_items::read(news_id)
    }

    #[view]
    fn get_user_profile(user: ContractAddress) -> UserProfile {
        user_profiles::read(user)
    }

    #[view]
    fn get_news_count() -> u256 {
        news_count::read()
    }

    #[view]
    fn has_user_liked_news(user: ContractAddress, news_id: u256) -> bool {
        user_favorites::read((user, news_id))
    }
}