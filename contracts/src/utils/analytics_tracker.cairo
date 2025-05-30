%lang starknet

from starknet::get_caller_address
from starknet::get_block_timestamp

@external
func track_interaction{syscall_ptr: felt*, pedersen_ptr, range_check_ptr}(
    action_id: felt
):
    // who called us
    let (user) = get_caller_address();
    // when
    let (ts) = get_block_timestamp();
    // emit an event for off-chain indexing
    emit InteractionTracked(user, action_id, ts);
    return ();
end

@event
func InteractionTracked(user: ContractAddress, action_id: felt, timestamp: felt):
end
