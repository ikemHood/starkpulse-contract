%lang starknet

from starkware.cairo.common.math import assert_not_zero
from openzeppelin.token.erc20.library import IERC20

@storage_var
struct VestingSchedule:
    total_amount: felt
    released: felt
    start_time: felt
    duration: felt

@event
func VestingScheduleCreated(beneficiary: felt, amount: felt):
end

@event
func TokensReleased(beneficiary: felt, amount: felt):
end

@external
func create_vesting_schedule{
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    beneficiary: felt,
    amount: felt,
    start_time: felt,
    duration: felt
):
    assert_not_zero(amount)
    
    let (current_schedule) = VestingSchedule.read(beneficiary)
    assert current_schedule.total_amount = 0  # No existing schedule
    
    VestingSchedule.write(
        beneficiary,
        amount,
        0,
        start_time,
        duration
    )
    
    VestingScheduleCreated.emit(beneficiary, amount)
    return ()
end

@external
func release_tokens{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    token_address: felt
):
    let beneficiary = msg.sender
    let (schedule) = VestingSchedule.read(beneficiary)
    
    let (current_time) = get_block_timestamp()
    let (releasable) = calculate_releasable(schedule, current_time)
    assert_not_zero(releasable)
    
    # Update storage
    VestingSchedule.write(
        beneficiary,
        schedule.total_amount,
        schedule.released + releasable,
        schedule.start_time,
        schedule.duration
    )
    
    # Transfer tokens
    let (erc20) = IERC20.transfer(
        token_address,
        beneficiary,
        releasable
    )
    
    TokensReleased.emit(beneficiary, releasable)
    return ()
end

@view
func calculate_releasable{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    schedule: VestingSchedule, 
    current_time: felt
) -> (amount: felt):
    if current_time <= schedule.start_time:
        return (0)
    end
    
    if current_time - schedule.start_time >= schedule.duration:
        return (schedule.total_amount - schedule.released)
    else:
        let time_passed = current_time - schedule.start_time
        let vested = schedule.total_amount * time_passed / schedule.duration
        return (vested - schedule.released)
    end
end