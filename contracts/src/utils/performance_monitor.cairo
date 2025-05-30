%lang starknet

@external
func log_gas_usage{syscall_ptr: felt*, range_check_ptr}(
    method_id: felt,  // a unique ID per method
    gas_used: felt
):
    // threshold → emit alert if too high
    if gas_used > 1_000_000 {
        emit GasAlert(method_id, gas_used);
    }
    emit GasLogged(method_id, gas_used);
    return ();
end

@event
func GasLogged(method_id: felt, gas_used: felt):
end

@event
func GasAlert(method_id: felt, gas_used: felt):
end
