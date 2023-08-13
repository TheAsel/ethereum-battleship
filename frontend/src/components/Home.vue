<script setup>
import { watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '../router'
import { AccountStore, GameStore } from '@/stores/store'
import { contractHandleGames, getEthAccounts, showToast } from '@/utils.js'

const account = AccountStore()
const game = GameStore()

const getRandomGame = async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.methods.getRandomGame().send({ from: accounts[0] })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}

watchEffect(async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.events.GameInfo({ filter: { sender: accounts[0] } }).on('data', (data) => {
      game.updateGameId(data.returnValues.gameId)
      game.updateCreator(data.returnValues.creator)
      game.updateBet(data.returnValues.bet)
      router.push({ name: 'acceptgame' })
    })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
})

watchEffect(async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.events.GameNotFound({ filter: { from: accounts[0] } }).on('data', () => {
      showToast('No game found', 'There are no games available, try again later', 'text-bg-warning')
    })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
})
</script>

<template>
  <div class="container mt-5">
    <div class="row align-items-center">
      <div class="col">
        <img
          alt="Ethereum Battleship logo"
          class="logo"
          src="../assets/logo.svg"
          width="125"
          height="125"
        />
      </div>
      <div class="col">
        <h1 class="display-2 me-5">Ethereum Battleship</h1>
      </div>
      <div class="col">
        <div class="d-flex" style="height: 200px">
          <div class="vr"></div>
        </div>
      </div>
      <div class="col-6">
        <div v-if="account.getWallet" class="d-grid gap-4 col-8 mx-auto">
          <RouterLink class="btn btn-success" type="button" to="/create">
            Create a new game
          </RouterLink>
          <RouterLink class="btn btn-success" type="button" to="/join"
            >Join a game by ID</RouterLink
          >
          <button class="btn btn-success" type="button" @click="getRandomGame">
            Join a random game
          </button>
        </div>
        <div v-else class="d-grid gap-4 col-8 mx-auto">
          <h3 class="text-center">Connect to MetaMask to play!</h3>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
