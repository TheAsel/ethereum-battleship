<script setup>
import { ref, watchEffect } from 'vue'
import router from '@/router'
import { GameStore } from '@/stores/store'
import { contractBattleship, getEthAccounts, showToast } from '@/utils.js'
import { StandardMerkleTree } from '@openzeppelin/merkle-tree'

const game = GameStore()
const selected = ref(new Array(64).fill(false))
const placed = ref(0)

const isPlaced = (row, col) => {
  return selected.value[(row - 1) * 8 + col - 1]
}

const place = (row, col) => {
  const pos = (row - 1) * 8 + col - 1
  if ((placed.value < 10 && !selected.value[pos]) || selected.value[pos]) {
    selected.value[pos] = !selected.value[pos]
    countPlaced()
  } else {
    showToast('Warning', 'You already placed all the ships', 'text-bg-warning')
  }
}

const countPlaced = () => {
  placed.value = selected.value.filter(Boolean).length
}

const generateSecureSalt = () => {
  const buffer = new Uint8Array(32)
  window.crypto.getRandomValues(buffer)
  let salt = ''
  for (let i = 0; i < buffer.length; i++) {
    salt += buffer[i].toString(16).padStart(2, '0')
  }
  return salt
}

const hashBoard = () => {
  const hashedArray = []
  for (let i = 0; i < selected.value.length; i++) {
    const salt = generateSecureSalt()
    hashedArray.push([selected.value[i], i, salt])
  }
  return hashedArray
}

const commitBoard = async () => {
  try {
    const hashedSelected = hashBoard()
    const tree = StandardMerkleTree.of(hashedSelected, ['bool', 'uint', 'string'])
    const accounts = await getEthAccounts()
    const contract = await contractBattleship(game.getGameId)
    contract.methods.commitBoard(tree.root).send({ from: accounts[0] })
    game.updateBoard(selected)
    game.updateTree(tree.dump())
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}

watchEffect(async () => {
  try {
    const contract = await contractBattleship()
    contract.events.GameStart().on('data', () => {
      router.push({ name: 'play' })
    })
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
})
</script>

<template>
  <div class="container mt-5">
    <div class="row align-items-center">
      <div class="col-5">
        <h3>Instructions</h3>
        <p>
          Select 10 cells to decide where to place your ships. When you're done, click "Commit
          board" and wait for your opponent to be ready.
        </p>
        <p>Left to place: {{ 10 - placed }}</p>
        <div class="row">
          <div class="col">
            <button
              class="btn btn-success"
              type="button"
              @click="commitBoard"
              v-bind:disabled="placed !== 10"
            >
              Commit board
            </button>
          </div>
        </div>
      </div>
      <div class="col">
        <div class="d-flex" style="height: 400px">
          <div class="vr"></div>
        </div>
      </div>
      <div class="col-6">
        <div class="d-grid gap-3 col-9 mx-auto">
          <table class="table">
            <tr v-for="row in 8" :key="row">
              <td v-for="col in 8" :key="col">
                <div :class="{ colored: isPlaced(row, col) }" @click="place(row, col)"></div>
              </td>
            </tr>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
td {
  width: 50px;
  height: 50px;
  border: 1px solid #dee2e6;
}
.colored {
  margin: auto;
  width: 100%;
  height: 100%;
  background-color: #198754;
}
</style>
