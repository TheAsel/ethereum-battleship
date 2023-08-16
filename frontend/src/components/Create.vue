<script setup>
import { ref, watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '@/router'
import { isConnected, contractHandleGames, getEthAccounts, showToast } from '@/utils.js'

if (!isConnected) {
  router.push({ name: 'home' })
}

const accounts = ref(await getEthAccounts())
const contract = ref(await contractHandleGames())
const bet = ''

const createGame = (bet) => {
  try {
    contract.value.methods.createGame(bet).send({ from: accounts.value[0] })
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events
      .GameCreated({ filter: { from: accounts.value[0] } })
      .on('data', (data) => {
        localStorage.setItem('gameId', data.returnValues.gameId)
        router.push({ name: 'waiting' })
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
        <div class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <label for="betAmount" class="form-label">Enter a bet amount to create a game:</label>
            <div class="col input-group">
              <span class="input-group-text">wei</span>
              <input
                type="number"
                class="form-control"
                id="betAmount"
                v-model="bet"
                placeholder="Enter the game's bet..."
                min="0"
                required
              />
            </div>
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="createGame(bet)">Create</button>
            </div>
          </form>
          <RouterLink class="btn btn-success" type="button" to="/">Back</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
