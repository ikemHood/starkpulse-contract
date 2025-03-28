%lang starknet

from starkware.cairo.common.math import assert_not_zero, assert_nn
from openzeppelin.access.ownable.library import Ownable

@storage_var
struct MarketData {
    price: felt,
    change_24h: felt,
    market_cap: felt,
    volume_24h: felt,
    last_updated: felt
}

@storage_var
func symbol_count() -> (count: felt) {
}

@event
func MarketDataUpdated(
    symbol: felt,
    price: felt,
    change_24h: felt,
    market_cap: felt,
    volume_24h: felt
) {
}

@external
func update_market_data{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    symbol: felt,
    price: felt,
    change_24h: felt,
    market_cap: felt,
    volume_24h: felt
) {
    Ownable.assert_only_owner()
    
    let timestamp = get_block_timestamp()
    
    MarketData.write(
        symbol,
        price,
        change_24h,
        market_cap,
        volume_24h,
        timestamp
    )
    
    MarketDataUpdated.emit(symbol, price, change_24h, market_cap, volume_24h)
    return ()
}

@view
func get_market_data{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    symbol: felt
) -> (
    price: felt,
    change_24h: felt,
    market_cap: felt,
    volume_24h: felt,
    last_updated: felt
) {
    let data = MarketData.read(symbol)
    return (data.price, data.change_24h, data.market_cap, data.volume_24h, data.last_updated)
}

@view
func get_bulk_market_data{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    symbols_len: felt,
    symbols: felt*
) -> (
    prices_len: felt,
    prices: felt*,
    changes_len: felt,
    changes: felt*,
    market_caps_len: felt,
    market_caps: felt*,
    volumes_len: felt,
    volumes: felt*
) {
    alloc_locals
    let (local prices: felt*) = alloc()
    let (local changes: felt*) = alloc()
    let (local market_caps: felt*) = alloc()
    let (local volumes: felt*) = alloc()
    
    let index = 0
    while (index < symbols_len) {
        let symbol = symbols[index]
        let (price, change, cap, volume, _) = get_market_data(symbol)
        
        assert prices[index] = price
        assert changes[index] = change
        assert market_caps[index] = cap
        assert volumes[index] = volume
        
        index = index + 1
    }
    
    return (
        symbols_len, prices,
        symbols_len, changes,
        symbols_len, market_caps,
        symbols_len, volumes
    )
}