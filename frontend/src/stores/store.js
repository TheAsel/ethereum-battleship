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

export const GameStore = defineStore('game', {
  state: () => ({ playerOne: '', playerTwo: '', agreedBet: '', opponent: '' }),
  getters: {
    getPlayerOne: (state) => state.playerOne,
    getPlayerTwo: (state) => state.playerTwo,
    getAgreedBet: (state) => state.agreedBet,
    getOpponent: (state) => state.opponent
  },
  actions: {
    updatePlayerOne(newPlayer) {
      this.playerOne = newPlayer
    },
    updatePlayerTwo(newPlayer) {
      this.playerTwo = newPlayer
    },
    updateAgreedBet(newBet) {
      this.agreedBet = newBet
    },
    updateOpponent(newOpponent) {
      this.opponent = newOpponent
    }
  }
})
