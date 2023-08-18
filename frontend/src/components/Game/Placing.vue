<script setup>
import { ref, watchEffect } from 'vue'
import router from '@/router'
import { GameStore } from '@/stores/store'
import {
  BOARD_SIDE,
  BOARD_SIZE,
  SHIP_COUNT,
  contractBattleship,
  getEthAccounts,
  showToast
} from '@/utils.js'
import { StandardMerkleTree } from '@openzeppelin/merkle-tree'

const game = GameStore()
const gameId = ref(localStorage.getItem('gameId'))
const selected = ref(new Array(BOARD_SIZE).fill(false))
const placed = ref(0)
const accounts = ref(await getEthAccounts())
const contract = ref(await contractBattleship(gameId.value))

const isPlaced = (row, col) => {
  return selected.value[(row - 1) * BOARD_SIDE + col - 1]
}

const place = (row, col) => {
  const pos = (row - 1) * BOARD_SIDE + col - 1
  if ((placed.value < SHIP_COUNT && !selected.value[pos]) || selected.value[pos]) {
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
  return window.BigInt('0x' + salt).toString(10)
}

const hashBoard = () => {
  const hashedArray = []
  for (let i = 0; i < selected.value.length; i++) {
    const salt = generateSecureSalt()
    hashedArray.push([i, selected.value[i], salt])
  }
  return hashedArray
}

const commitBoard = () => {
  try {
    const hashedSelected = hashBoard()
    const tree = StandardMerkleTree.of(hashedSelected, ['uint8', 'bool', 'uint256'])
    contract.value.methods.commitBoard(tree.root).send({ from: accounts.value[0] })
    localStorage.setItem('board', JSON.stringify(selected))
    localStorage.setItem('tree', JSON.stringify(tree.dump()))
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events.GameStart().on('data', () => {
      const playerTurn = contract.value.methods.playerTurn().call()
      game.updatePlayerTurn(playerTurn)
      router.push({ name: 'play' })
    })
  } catch (err) {
    showToast('Error', err.message)
  }
})
</script>

<template>
  <div class="container mt-5">
    <div class="row align-items-center">
      <div class="col-5">
        <h3>Instructions</h3>
        <p>
          Select {{ SHIP_COUNT }} cells to decide where to place your ships. When you're done, click
          "Commit board" and wait for your opponent to be ready.
        </p>
        <p>Left to place: {{ SHIP_COUNT - placed }}</p>
        <div class="row">
          <div class="col">
            <button
              class="btn btn-success"
              type="button"
              @click="commitBoard"
              v-bind:disabled="placed !== SHIP_COUNT"
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
            <tr v-for="row in BOARD_SIDE" :key="row">
              <td v-for="col in BOARD_SIDE" :key="col" @click="place(row, col)">
                <div :class="{ ship: isPlaced(row, col) }"></div>
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

.ship {
  width: 100%;
  height: 100%;
  background-image: url('@/assets/green-peg.svg');
  background-size: 100% 100%;
}

td:hover {
  border: 2px solid #dc3545;
}
</style>
