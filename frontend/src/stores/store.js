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
  state: () => ({ gameId: '', creator: '', bet: '', opponent: '', board: '', tree: '' }),
  getters: {
    getGameId: (state) => state.gameId,
    getCreator: (state) => state.creator,
    getBet: (state) => state.bet,
    getOpponent: (state) => state.opponent,
    getBoard: (state) => state.board,
    getTree: (state) => state.tree
  },
  actions: {
    updateGameId(newGameId) {
      this.gameId = newGameId
    },
    updateCreator(newCreator) {
      this.creator = newCreator
    },
    updateBet(newBet) {
      this.bet = newBet
    },
    updateOpponent(newOpponent) {
      this.opponent = newOpponent
    },
    updateBoard(newBoard) {
      this.board = newBoard
    },
    updateTree(newTree) {
      this.tree = newTree
    }
  }
})
