<script setup>
import { ref } from 'vue'
import { RouterView } from 'vue-router'
import router from '@/router'
import { GameStore } from '@/stores/store'
import { isConnected, contractBattleship, getEthAccounts, showToast } from '@/utils.js'

const game = GameStore()
const gameId = ref(localStorage.getItem('gameId'))

if (!isConnected || gameId.value == null) {
  router.push({ name: 'home' })
}

const accounts = ref(await getEthAccounts())
const contract = ref(await contractBattleship(gameId.value))

const Phase = {
  Waiting: window.BigInt(0),
  Paying: window.BigInt(1),
  Placing: window.BigInt(2),
  Playing: window.BigInt(3)
}

try {
  const playerOne = await contract.value.methods.playerOne().call()
  const playerTwo = await contract.value.methods.playerTwo().call()
  if (!(accounts.value[0] == playerOne || accounts.value[0] == playerTwo)) {
    showToast('Error', 'You are not a player of this game')
    router.push({ name: 'home' })
  } else {
    const opponent = accounts.value[0] == playerOne ? playerTwo : playerOne
  }
  const gamePhase = await contract.value.methods.gamePhase().call()
  console.log(gamePhase)
  console.log(Phase.Paying)
  switch (gamePhase) {
    case Phase.Paying:
      router.push({ name: 'deposit' })
      break
    case Phase.Placing:
      router.push({ name: 'placing' })
      break
    case Phase.Playing:
      router.push({ name: 'play' })
      break
    default:
      router.push({ name: 'home' })
      break
  }
} catch (err) {
  showToast('Error', err.message)
  router.push({ name: 'home' })
}

const report = () => {
  try {
    contract.value.methods.report().send({ from: accounts.value[0] })
  } catch (err) {
    showToast('Error', err.message)
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
