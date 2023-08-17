<script setup>
import { ref, watchEffect } from 'vue'
import { GameStore } from '@/stores/store'
import { contractBattleship, getEthAccounts, showToast } from '@/utils.js'
import { StandardMerkleTree } from '@openzeppelin/merkle-tree'

const game = GameStore()
const gameId = ref(localStorage.getItem('gameId'))
const accounts = ref(await getEthAccounts())
const contract = ref(await contractBattleship(gameId.value))
const playerTurn = ref(game.getPlayerTurn)
const yourTurn = ref(playerTurn.value === accounts.value[0])
const board = JSON.parse(localStorage.getItem('board'))
const tree = StandardMerkleTree.load(JSON.parse(localStorage.getItem('tree')))
const opponent = ref(game.getOpponent)
const yourShots = ref(new Array(64))
const opponentShots = ref(new Array(64))
const unconfirmedShot = ref()

const updateShots = async () => {
  try {
    playerTurn.value = await contract.value.methods.playerTurn().call()
    yourTurn.value = playerTurn.value === accounts.value[0]
    yourShots.value = await contract.value.methods.getPlayerShots(accounts.value[0]).call()
    console.log('Your shots: ', yourShots.value)
    opponentShots.value = await contract.value.methods.getPlayerShots(opponent.value).call()
    console.log("Opponent's shots: ", opponentShots.value)
    unconfirmedShot.value = opponentShots.value.filter((i) => i.value === Cell.Unconfirm)
    console.log('Unconfirmed shot: ', unconfirmedShot.value[0])
  } catch (err) {
    showToast('Error', err.message)
  }
}

updateShots()

const Cell = {
  None: window.BigInt(0),
  Unconfirm: window.BigInt(1),
  Sunk: window.BigInt(2),
  Miss: window.BigInt(3)
}

const shoot = async (row, col) => {
  try {
    if (canShoot(row, col)) {
      const pos = (row - 1) * 8 + col - 1
      const firstShot = unconfirmedShot.value.length === 0
      if (firstShot) {
        await contract.value.methods.shoot(pos).send({ from: accounts.value[0] })
      } else {
        const posCheck = parseInt(unconfirmedShot.value[0].index)
        console.log(posCheck)
        const values = tree.values.find((v) => v.value[0] === posCheck).value
        console.log('values: ', values)
        const proof = tree.getProof(posCheck)
        await contract.value.methods
          .confirmAndShoot(values[0], values[1], window.BigInt(values[2]), proof, pos)
          .send({ from: accounts.value[0] })
      }
    }
  } catch (err) {
    showToast('Error', err.message)
  }
}

watchEffect(() => {
  try {
    contract.value.events.ShotTaken().on('data', (data) => {
      if (data.returnValues.player === opponent.value) {
        showToast('Your turn', "Your opponent took a shot! It's now your turn", 'text-bg-success')
      }
      updateShots()
    })
  } catch (err) {
    showToast('Error', err.message)
  }
})

const canShoot = (row, col) => {
  return cellValue(row, col, false) === '' && yourTurn.value
}

const cellValue = (row, col, yourBoard) => {
  try {
    var cellValue = ''
    const pos = (row - 1) * 8 + col - 1
    if (yourBoard) {
      cellValue = board._value[pos] ? 'ship' : ''
    }
    const playerShots = !yourBoard ? yourShots.value : opponentShots.value
    const shot = playerShots.filter((i) => parseInt(i.index) === pos)
    if (shot.length > 0) {
      switch (shot[0].value) {
        case Cell.Unconfirm:
          cellValue = 'unconfirm'
          break
        case Cell.Sunk:
          cellValue = 'sunk'
          break
        case Cell.Miss:
          cellValue = 'miss'
          break
        default:
          break
      }
    }
    return cellValue
  } catch (err) {
    showToast('Error', err.message)
  }
}
</script>

<template>
  <div class="container">
    <div class="row">
      <div class="col">
        <div class="card mt-5">
          <h5 class="card-header text-center">Instructions</h5>
          <ul class="list-group list-group-flush">
            <li class="list-group-item">
              Take turns taking shots. When all the ships of a player have been sunk, the game will
              end.
            </li>
            <li class="list-group-item">
              <p class="card-text">🟩 - Your ships</p>
              <p class="card-text">🟥 - Sunk ship</p>
              <p class="card-text">🟦 - Missed ship</p>
              <p class="card-text">🟨 - Unconfirmed</p>
            </li>
            <li class="list-group-item text-center">
              <p v-if="yourTurn" class="card-text fw-bold text-success">Your turn</p>
              <p v-else class="card-text fw-bold text-danger">Opponent's turn</p>
            </li>
          </ul>
        </div>
      </div>
      <div class="col-auto">
        <table class="table caption-top">
          <caption>
            Opponent's board:
          </caption>
          <tr v-for="opprow in 8" :key="opprow">
            <td
              @click="shoot(opprow, oppcol)"
              :class="{ crosshair: canShoot(opprow, oppcol) }"
              v-for="oppcol in 8"
              :key="oppcol"
            >
              <div :class="cellValue(opprow, oppcol, false)"></div>
            </td>
          </tr>
        </table>
      </div>
      <div class="col-md-auto ms-4 me-4">
        <div class="d-flex" style="height: 450px">
          <div class="vr"></div>
        </div>
      </div>
      <div class="col-auto">
        <table class="table caption-top">
          <caption>
            Your board:
          </caption>
          <tr v-for="yourrow in 8" :key="yourrow">
            <td v-for="yourcol in 8" :key="yourcol">
              <div :class="cellValue(yourrow, yourcol, true)"></div>
            </td>
          </tr>
        </table>
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

.sunk {
  width: 100%;
  height: 100%;
  background-image: url('@/assets/red-peg.svg');
  background-size: 100% 100%;
}

.miss {
  width: 100%;
  height: 100%;
  background-image: url('@/assets/blue-peg.svg');
  background-size: 100% 100%;
}

.unconfirm {
  width: 100%;
  height: 100%;
  background-image: url('@/assets/yellow-peg.svg');
  background-size: 100% 100%;
}

.crosshair:hover {
  content: url('@/assets/crosshair.svg');
  padding: 2px;
  border: 2px solid #dc3545;
}
</style>
