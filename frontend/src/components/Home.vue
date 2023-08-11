<script setup>
import { RouterLink } from 'vue-router'
import { AccountStore } from '@/stores/store'
import { watchEffect } from 'vue'
import router from '../router'
import { contractHandleGames, getEthAccounts } from '@/utils.js'

const account = AccountStore()

watchEffect(async () => {
  const accounts = await getEthAccounts()
  const contract = await contractHandleGames()
  contract.events.GameCreated({ filter: { from: accounts[0] } }).on('data', (data) => {
    router.push({ name: 'waiting', query: { gameId: data.returnValues.gameId } })
  })
})

const createGame = async () => {
  const accounts = await getEthAccounts()
  const contract = await contractHandleGames()
  contract.methods.createGame().send({ from: accounts[0] })
}

const joinRandomGame = async () => {
  const accounts = await getEthAccounts()
  const contract = await contractHandleGames()
  contract.methods.joinRandomGame().send({ from: accounts[0] })
}
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
          <button class="btn btn-success" type="button" @click="createGame">
            Create a new game
          </button>
          <RouterLink class="btn btn-success" type="button" to="/join"
            >Join a game by ID</RouterLink
          >
          <button class="btn btn-success" type="button" @click="joinRandomGame">
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
