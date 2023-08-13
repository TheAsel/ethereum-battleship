<script setup>
import { ref, watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '../router'
import { GameStore } from '@/stores/store'
import { isConnected, contractHandleGames, getEthAccounts, showToast } from '@/utils.js'

const game = GameStore()

if (!isConnected) {
  router.push({ name: 'home' })
}

const gameid = ref(game.getGameId)
const gameCreator = ref(game.getCreator)
const gameBet = ref(game.getBet)

const joinGame = async (gameid) => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.methods.joinGame(gameid).send({ from: accounts[0] })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}

watchEffect(async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.events.GameJoined({ filter: { by: accounts[0] } }).on('data', (data) => {
      game.updateOpponent(game.getCreator)
      router.push({ name: 'placing', query: { gameId: data.returnValues.gameId } })
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
        <div class="d-grid gap-4 col-9 mx-auto">
          <form class="row">
            <label for="gameid" class="form-label">Game's ID:</label>
            <div>
              <input
                type="text"
                class="form-control"
                id="gameid"
                v-model="gameid"
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
          <form class="row justify-content-md-center">
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="joinGame(gameid)">
                Accept
              </button>
            </div>
            <div class="col-auto">
              <RouterLink class="btn btn-danger" type="button" to="/">Reject</RouterLink>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>