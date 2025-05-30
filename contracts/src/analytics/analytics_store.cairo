%lang starknet

@storage_var
func interaction_count(user: ContractAddress, action_id: felt) -> (count: felt):
end

@external
func track_interaction{syscall_ptr: felt*, range_check_ptr}(
    user: ContractAddress,
    action_id: felt
):
    // bump the on-chain counter
    let (old) = interaction_count.read(user, action_id);
    interaction_count.write(user, action_id, old + 1);
    return ();
end

@view
func get_user_action_count{syscall_ptr: felt*, range_check_ptr}(
    user: ContractAddress,
    action_id: felt
) -> (count: felt):
    let (cnt) = interaction_count.read(user, action_id);
    return (cnt);
end
