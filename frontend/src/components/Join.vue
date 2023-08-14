<script setup>
import { watchEffect } from 'vue'
import { RouterLink } from 'vue-router'
import router from '@/router'
import { GameStore } from '@/stores/store'
import { isConnected, contractHandleGames, getEthAccounts, showToast } from '@/utils.js'

const game = GameStore()
const gameid = ''

if (!isConnected) {
  router.push({ name: 'home' })
}

const getGameInfo = async (gameid) => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.methods.getGameInfo(gameid).send({ from: accounts[0] })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}

watchEffect(async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractHandleGames()
    contract.events.GameInfo({ filter: { from: accounts[0] } }).on('data', (data) => {
      game.updateGameId(data.returnValues.gameId)
      game.updateCreator(data.returnValues.creator)
      game.updateBet(data.returnValues.bet)
      router.push({ name: 'acceptgame' })
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
        <div class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <div class="col">
              <input
                type="text"
                class="form-control"
                v-model="gameid"
                placeholder="Enter the game's ID..."
              />
            </div>
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="getGameInfo(gameid)">
                Join
              </button>
            </div>
          </form>
          <RouterLink class="btn btn-success" type="button" to="/">Back</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
