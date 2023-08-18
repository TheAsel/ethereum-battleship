<script setup>
import { ref, watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '@/router'
import {
  isConnected,
  contractHandleGames,
  contractBattleship,
  getEthAccounts,
  showToast
} from '@/utils.js'

const gameId = ref(localStorage.getItem('gameId'))
const accounts = ref()
const contract = ref()
const gameCreator = ref()
const gameBet = ref()

try {
  accounts.value = await getEthAccounts()
  contract.value = await contractHandleGames()
  const contractGame = await contractBattleship(gameId.value)
  gameCreator.value = await contractGame.methods.playerOne().call()
  gameBet.value = await contractGame.methods.agreedBet().call()
} catch (err) {
  showToast('Error', err.message)
  router.push({ name: 'home' })
}

if (!isConnected || gameId.value === '') {
  router.push({ name: 'home' })
}

const joinGame = () => {
  try {
    contract.value.methods.joinGame(gameId.value).send({ from: accounts.value[0] })
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events.GameJoined({ filter: { by: accounts.value[0] } }).on('data', () => {
      localStorage.setItem('gameId', gameId.value)
      router.push({ name: 'deposit' })
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
        <div class="d-grid gap-3 col-9 mx-auto">
          <form class="row">
            <label for="gameId" class="form-label">Game's ID:</label>
            <div>
              <input
                type="text"
                class="form-control"
                id="gameId"
                v-model="gameId"
                disabled
                readonly
              />
            </div>
          </form>
          <form class="row">
            <label for="gamecreator" class="form-label">Game's creator:</label>
            <div>
              <input
                type="text"
                class="form-control"
                id="gamecreator"
                v-model="gameCreator"
                disabled
                readonly
              />
            </div>
          </form>
          <form class="row">
            <label for="gamebet" class="form-label">Game's bet amount:</label>
            <div class="input-group">
              <span class="input-group-text">wei</span>
              <input
                type="text"
                class="form-control"
                id="gamebet"
                v-model="gameBet"
                disabled
                readonly
              />
            </div>
          </form>
          <form class="row gap-4 justify-content-md-center">
            <div class="col-auto">
              <RouterLink class="btn btn-danger" type="button" to="/">Reject</RouterLink>
            </div>
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="joinGame">Join game</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
