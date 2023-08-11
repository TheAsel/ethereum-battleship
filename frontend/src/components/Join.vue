<script setup>
import { RouterLink } from 'vue-router'
import { contractHandleGames, getEthAccounts } from '@/utils.js'

const gameid = ''

const joinGameID = async (gameid) => {
  const accounts = await getEthAccounts()
  const contract = await contractHandleGames()
  contract.methods.joinIdGame(gameid).send({ from: accounts[0] })
}
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
                placeholder="Enter the game ID..."
              />
            </div>
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="joinGameID(gameid)" to="/">
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
