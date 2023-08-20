<script setup>
import { ref, watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '@/router'
import { AccountStore } from '@/stores/store'
import { contractHandleGames, getEthAccounts, showToast } from '@/utils.js'

const account = AccountStore()
const accounts = ref()
const contract = ref()

try {
  accounts.value = await getEthAccounts()
  contract.value = await contractHandleGames()
} catch (err) {
  showToast('Error', err.message)
}

const getRandomGame = async () => {
  try {
    accounts.value = await getEthAccounts()
    contract.value.methods.getRandomGame().send({ from: accounts.value[0] })
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events.GameInfo({ filter: { sender: accounts.value[0] } }).on('data', (data) => {
      localStorage.setItem('gameId', data.returnValues.gameId)
      router.push({ name: 'acceptgame' })
    })
  } catch (err) {
    showToast('Error', err.message)
  }
})

watchEffect(() => {
  try {
    contract.value.events.GameNotFound({ filter: { from: accounts.value[0] } }).on('data', () => {
      showToast('No game found', 'There are no games available, try again later', 'text-bg-warning')
    })
  } catch (err) {
    showToast('Error', err.message)
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
          src="@/assets/logo.svg"
          width="125"
          height="125"
        />
      </div>
      <div class="col">
        <h1 class="display-2 me-5">Ethereum Battleship</h1>
      </div>
      <div class="col">
        <div class="d-flex" style="height: 300px">
          <div class="vr"></div>
        </div>
      </div>
      <div class="col-6">
        <div v-if="account.getWallet" class="d-grid gap-4 col-8 mx-auto">
          <RouterLink class="btn btn-success" type="button" to="/create">
            Create a new game
          </RouterLink>
          <hr />
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
