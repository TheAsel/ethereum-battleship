<script setup>
import { ref } from 'vue'
import router from '@/router'
import { contractBattleship, getEthAccounts, showToast } from '@/utils.js'
import { StandardMerkleTree } from '@openzeppelin/merkle-tree'

const gameId = ref(localStorage.getItem('gameId'))
const accounts = ref()
const contract = ref()
const winner = ref()
const opponent = ref()
const tree = StandardMerkleTree.load(JSON.parse(localStorage.getItem('tree')))

try {
  accounts.value = await getEthAccounts()
  contract.value = await contractBattleship(gameId.value)
  winner.value = (await contract.value.methods.winner().call()) === accounts.value[0]
  const playerOne = await contract.value.methods.playerOne().call()
  const playerTwo = await contract.value.methods.playerTwo().call()
  opponent.value = accounts.value[0] == playerOne ? playerTwo : playerOne
} catch (err) {
  showToast('Error', err.message)
  router.push({ name: 'home' })
}

const verify = async () => {
  try {
    const opponentShots = await contract.value.methods.getPlayerShots(opponent.value).call()
    const all = Array.from(Array(64).keys())
    const { proof, proofFlags, leaves } = tree.getMultiProof(
      all.filter((c) => !opponentShots.find((i) => parseInt(i.index) === c))
    )
    const indexes = []
    const cells = []
    const salts = []
    leaves.forEach((i) => {
      indexes.push(i[0])
      cells.push(i[1])
      salts.push(window.BigInt(i[2]))
    })
    await contract.value.methods
      .boardCheck(indexes, cells, salts, proof, proofFlags)
      .send({ from: accounts.value[0] })
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
              <h3>You won! Verify your board to withdraw the prize</h3>
            </div>
          </form>
          <button @click="verify" class="btn btn-success" type="button" to="/">Send board</button>
        </div>
        <div v-else class="d-grid gap-4 col-11 mx-auto">
          <form class="row">
            <div class="col text-center">
              <h3>You appear to have lost, wait for the opponent's board to be verified</h3>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
