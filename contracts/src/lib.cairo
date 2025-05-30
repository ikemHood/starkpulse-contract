// StarkPulse Contract - Library File
// Exporta todos los módulos del proyecto

// Módulos de interfaces
mod interfaces {
    pub mod i_erc20;
    pub mod i_token_vesting;
    pub mod i_transaction_monitor;
    pub mod i_portfolio_tracker;
}

// Módulos de utilidades
mod utils {
    pub mod access_control;
}

// Módulos principales
mod vesting {
    pub mod TokenVesting;
}

// Tests
#[cfg(test)]
mod tests {
    pub mod test_token_vesting;
    pub mod test_user_auth;
    pub mod test_contract_interaction;
    pub mod test_erc20_token;
    pub mod test_starkpulse_token;
}
