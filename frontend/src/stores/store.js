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
  state: () => ({ board: '', tree: '' }),
  getters: {
    getBoard: (state) => state.board,
    getTree: (state) => state.tree
  },
  actions: {
    updateBoard(newBoard) {
      this.board = newBoard
    },
    updateTree(newTree) {
      this.tree = newTree
    }
  }
})
