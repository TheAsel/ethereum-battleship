<script setup>
import { RouterLink } from 'vue-router'
import router from '@/router'
import { isConnected, contractBattleship, showToast } from '@/utils.js'

const gameId = ''

if (!isConnected) {
  router.push({ name: 'home' })
}

const getGameInfo = async (gameId) => {
  try {
    await contractBattleship(gameId)
    localStorage.setItem('gameId', gameId)
    router.push({ name: 'acceptgame' })
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
        <div class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <div class="col">
              <input
                type="text"
                class="form-control"
                v-model="gameId"
                placeholder="Enter the game's ID..."
              />
            </div>
            <div class="col-auto">
              <button class="btn btn-success" type="button" @click="getGameInfo(gameId)">
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
