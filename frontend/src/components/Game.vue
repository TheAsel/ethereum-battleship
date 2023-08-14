<script setup>
import { ref } from 'vue'
import { RouterView } from 'vue-router'
import router from '@/router'
import { GameStore } from '@/stores/store'
import { isConnected, contractBattleship, getEthAccounts, showToast } from '@/utils.js'

const game = GameStore()
const gameId = ref(game.getGameId)

if (!isConnected || gameId.value === '') {
  router.push({ name: 'home' })
}

const report = async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractBattleship(game.getGameId)
    contract.methods.report(game.getOpponent).send({ from: accounts[0] })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}
</script>

<template>
  <div class="card border-success m-2">
    <div class="d-flex">
      <div class="card-body">Game ID: {{ gameId }}</div>
      <button class="btn btn-danger m-2" type="button" @click="report">Report opponent</button>
    </div>
  </div>
  <RouterView />
</template>

<style scoped></style>
