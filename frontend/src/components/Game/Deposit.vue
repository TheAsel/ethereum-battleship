<script setup>
import { ref, watchEffect } from 'vue'
import router from '@/router'
import { GameStore } from '@/stores/store'
import { contractBattleship, getEthAccounts, showToast } from '@/utils.js'

const game = GameStore()
const gameId = ref(game.getGameId)
const gameBet = ref('')

try {
  const contract = await contractBattleship(gameId.value)
  gameBet.value = await contract.methods.agreedBet().call()
} catch (err) {
  showToast('Error', err.message)
  router.push({ name: 'home' })
}

const depositBet = async () => {
  try {
    const accounts = await getEthAccounts()
    const contract = await contractBattleship(gameId.value)
    contract.methods.depositBet().send({ from: accounts[0], value: gameBet.value })
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(async () => {
  try {
    const contract = await contractBattleship(gameId.value)
    contract.events.BetPayed().on('data', () => {
      router.push({ name: 'placing' })
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
        <div class="d-flex" style="height: 200px">
          <div class="vr"></div>
        </div>
      </div>
      <div class="col-6">
        <div class="d-grid gap-4 col-11 mx-auto">
          <h5>When both players have deposited, the game will start:</h5>
          <form class="row">
            <div class="col input-group">
              <span class="input-group-text">wei</span>
              <input type="text" class="form-control" v-model="gameBet" disabled readonly />
            </div>
            <div class="col-md-auto">
              <button className="btn btn-success" type="button" @click="depositBet">
                Deposit bet
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
