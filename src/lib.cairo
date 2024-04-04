use starknet::ContractAddress;

#[starknet::interface]
pub trait I_MonSmartContract<TContractState>{
    fn name(self : @TContractState) -> felt252;
    fn symbol(self : @TContractState) -> felt252;
    fn decimals(self : @TContractState) -> u8;
    fn totalSupply(self : @TContractState) -> u256;
    fn balanceOf(self : @TContractState, _owner : ContractAddress) -> u256;
    fn transfer(ref self : TContractState, _to : ContractAddress, _value : u256) -> bool;
    fn transferFrom(ref self : TContractState, _from : ContractAddress, _to : ContractAddress, _value : u256) -> bool;
    fn approve(ref self : TContractState, _spender : ContractAddress, _value : u256) -> bool;
    fn allowance(self : @TContractState, _owner : ContractAddress, _spender : ContractAddress) -> u256;
}

#[starknet::contract]
mod MonSmartContract{
    use core::starknet::event::EventEmitter;
use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use super::I_MonSmartContract;

    #[storage]
    struct Storage{
        name : felt252,
        symbol : felt252,
        decimals : u8,
        totalSupply : u256,
        balances : LegacyMap::<ContractAddress, u256>,
        allowances : LegacyMap::<(ContractAddress, ContractAddress), u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event{
        Transfer : Transfer,
        Approval : Approval
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer{
        _from : ContractAddress,
        _to : ContractAddress,
        _value : u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval{
        _owner : ContractAddress,
        _spender : ContractAddress,
        _value : u256
    }

    #[constructor]
    fn constructor(ref self : ContractState, owner : ContractAddress){
        self.name.write('Franc Congolais');
        self.symbol.write('CDF');
        self.decimals.write(6_u8);
        let total_supply = 10_000_000_000_000_u256;
        self.totalSupply.write(total_supply);
        // self.transfer(owner, total_supply);
        self.balances.write(owner, total_supply);
        self.emit(
            Transfer{
                _from : contract_address_const::<0>(),
                _to : owner, 
                _value : total_supply
            }
        );

    }

    #[abi(embed_v0)]
    impl MonStractContract of I_MonSmartContract<ContractState>{
        fn name(self : @ContractState) -> felt252{
            self.name.read()
        }

        fn symbol(self : @ContractState) -> felt252{
            self.symbol.read()
        }

        fn decimals(self : @ContractState) -> u8{
            self.decimals.read()
        }

        fn totalSupply(self : @ContractState) -> u256{
            self.totalSupply.read()
        }

        fn balanceOf(self : @ContractState, _owner : ContractAddress) -> u256{
            self.balances.read(_owner)
        }

        fn transfer(ref self : ContractState, _to : ContractAddress, _value : u256) -> bool {
            let me = get_caller_address();
            self.transfer_helper(me, _to, _value);
            true
        }

        fn transferFrom(ref self : ContractState, _from : ContractAddress, _to : ContractAddress, _value : u256) -> bool {
            let me = get_caller_address();
            let _allowance = self.allowances.read((_from, me));
            if _allowance > _value {
                self.transfer_helper(_from, _to, _value);
                true
            } else {
                false
            }
        }

        fn approve(ref self : ContractState, _spender : ContractAddress, _value : u256) -> bool {
            let me = get_caller_address();
            self.allowances.write((me, _spender), _value);
            self.emit(Approval{
                    _owner : me,
                    _spender : _spender,
                    _value : _value
                });
            true
        }

        fn allowance(self : @ContractState, _owner : ContractAddress, _spender : ContractAddress) -> u256{
            self.allowances.read((_owner, _spender))

        }


    }

    #[generate_trait]
    impl StorageImpl of StorageTrait{
        fn transfer_helper(ref self : ContractState, _from : ContractAddress, _to : ContractAddress, _value : u256) -> bool{
            let balance_from = self.balances.read(_from);
            if balance_from > _value {
                self.balances.write(_from, balance_from - _value);
                self.balances.write(_to, self.balances.read(_to) + _value);
                self.emit(Transfer{
                    _from : _from,
                    _to : _to,
                    _value : _value
                });
                true
            } else {
                false
            }
            
        }
    }

    

}