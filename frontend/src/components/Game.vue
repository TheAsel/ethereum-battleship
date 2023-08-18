<script setup>
import { ref, watchEffect } from 'vue'
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
const gamePhase = ref()
const canReport = ref(false)

const Phase = {
  Waiting: window.BigInt(0),
  Paying: window.BigInt(1),
  Placing: window.BigInt(2),
  Playing: window.BigInt(3),
  Verifying: window.BigInt(4),
  Withdraw: window.BigInt(5),
  End: window.BigInt(6)
}

try {
  const playerOne = await contract.value.methods.playerOne().call()
  game.updatePlayerOne(playerOne)
  const playerTwo = await contract.value.methods.playerTwo().call()
  game.updatePlayerTwo(playerTwo)
  if (!(accounts.value[0] == playerOne || accounts.value[0] == playerTwo)) {
    showToast('Error', 'You are not a player of this game')
    router.push({ name: 'home' })
  } else {
    const opponent = accounts.value[0] == playerOne ? playerTwo : playerOne
    game.updateOpponent(opponent)
    gamePhase.value = await contract.value.methods.gamePhase().call()
    canReport.value = !(gamePhase.value === Phase.Withdraw || gamePhase.value === Phase.End)
    switch (gamePhase.value) {
      case Phase.Paying:
        router.push({ name: 'deposit' })
        break
      case Phase.Placing:
        router.push({ name: 'placing' })
        break
      case Phase.Playing:
        router.push({ name: 'play' })
        break
      case Phase.Verifying:
        router.push({ name: 'verify' })
        break
      case Phase.Withdraw:
        router.push({ name: 'withdraw' })
        break
      default:
        router.push({ name: 'home' })
        break
    }
    const agreedBet = await contract.value.methods.agreedBet().call()
    game.updateAgreedBet(agreedBet)
    const playerTurn = await contract.value.methods.playerTurn().call()
    game.updatePlayerTurn(playerTurn)
  }
} catch (err) {
  showToast('Error', err.message)
  router.push({ name: 'home' })
}

const report = () => {
  try {
    if (canReport.value) {
      contract.value.methods.report().send({ from: accounts.value[0] })
    }
  } catch (err) {
    showToast('Error', err.message)
  }
}

const forfeit = () => {
  try {
    if (canReport.value) {
      contract.value.methods.forfeit().send({ from: accounts.value[0] })
    }
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events.Won().on('data', () => {
      router.push({ name: 'verify' })
    })
  } catch (err) {
    showToast('Error', err.message)
  }
})

watchEffect(() => {
  try {
    contract.value.events.WinnerVerified().on('data', () => {
      router.push({ name: 'withdraw' })
    })
  } catch (err) {
    showToast('Error', err.message)
  }
})
</script>

<template>
  <div class="card border-success m-2">
    <div class="d-flex">
      <div class="card-body">Game ID: {{ gameId }}</div>
      <button v-if="canReport" class="btn btn-warning m-2" type="button" @click="forfeit">
        Forfeit
      </button>
      <button v-if="canReport" class="btn btn-danger m-2" type="button" @click="report">
        Report opponent
      </button>
    </div>
  </div>
  <RouterView />
</template>

<style scoped></style>
