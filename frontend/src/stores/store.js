import { defineStore } from 'pinia'

export const AccountStore = defineStore('account', {
  state: () => ({ wallet: '' }),
  getters: {
    getWallet: (state) => state.wallet
  },
  actions: {
    updateAccount(newAccount) {
      this.wallet = newAccount
    }
  }
})

export const HandleGamesContract = defineStore('handlegamecontract', {
  state: () => ({ contract: '' }),
  getters: {
    getContract: (state) => state.contract
  },
  actions: {
    updateContract(newContract) {
      this.contract = newContract
    }
  }
})

export const BattleshipContract = defineStore('battleshipcontract', {
  state: () => ({ contract: '' }),
  getters: {
    getContract: (state) => state.contract
  },
  actions: {
    updateContract(newContract) {
      this.contract = newContract
    }
  }
})
