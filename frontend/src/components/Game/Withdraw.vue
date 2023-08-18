<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { contractBattleship, getEthAccounts, showToast } from '@/utils.js'

const gameId = ref(localStorage.getItem('gameId'))
const accounts = ref(await getEthAccounts())
const contract = ref(await contractBattleship(gameId.value))
const winner = ref((await contract.value.methods.winner().call()) === accounts.value[0])
const withdrawn = ref(false)

const withdraw = async () => {
  try {
    await contract.value.methods.withdraw().send({ from: accounts.value[0] })
    withdrawn.value = true
  } catch (err) {
    showToast('Error', err.message)
  }
}
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
        <div v-if="winner" class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <div class="col text-center">
              <h3 v-if="!withdrawn">Congratulations, you won!</h3>
              <h3 v-else>Prize added to your wallet. Thank you for playing!</h3>
            </div>
          </form>
          <button v-if="!withdrawn" @click="withdraw" class="btn btn-success" type="button" to="/">
            Withdraw prize
          </button>
          <RouterLink v-else class="btn btn-success" type="button" to="/"
            >Back to Homepage</RouterLink
          >
        </div>
        <div v-else class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <div class="col text-center">
              <h3>You lost... Better luck next time!</h3>
            </div>
          </form>
          <RouterLink class="btn btn-success" type="button" to="/">Back to Homepage</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
