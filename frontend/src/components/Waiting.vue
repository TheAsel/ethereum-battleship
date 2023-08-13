<script setup>
import { ref, watchEffect } from 'vue'
import useClipboard from 'vue-clipboard3'
import router from '../router'
import { useRoute } from 'vue-router'
import { GameStore } from '@/stores/store'
import { isConnected, contractHandleGames, showToast } from '@/utils.js'

const game = GameStore()
const route = useRoute()

const gameid = ref(route.query.gameId)

if (!isConnected || typeof gameid.value === 'undefined') {
  router.push({ name: 'home' })
}

if (gameid.value) {
  showToast('Game created', 'Waiting for a player to join')
}

const { toClipboard } = useClipboard()

const copy = async () => {
  await toClipboard(gameid.value)
  showToast('Copied', 'Game ID copied to clipboard')
}

watchEffect(async () => {
  try {
    const contract = await contractHandleGames()
    contract.events.GameJoined({ filter: { gameId: gameid.value } }).on('data', (data) => {
      game.updateOpponent(data.returnValues.by)
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
        <div class="d-grid gap-4 col-11 mx-auto">
          <h5>Share this game ID with a friend to play:</h5>
          <form class="row">
            <div class="col">
              <input type="text" class="form-control" v-model="gameid" disabled readonly />
            </div>
            <div class="col-auto">
              <button className="btn btn-success" type="button" @click="copy">Copy ID</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
