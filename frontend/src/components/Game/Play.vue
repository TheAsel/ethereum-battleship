<script setup>
import { ref } from 'vue'

const yourTurn = ref(true)
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
          <tr v-for="row in 8" :key="row">
            <td v-for="col in 8" :key="col"></td>
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
          <tr v-for="row in 8" :key="row">
            <td v-for="col in 8" :key="col"></td>
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
  margin: auto;
  width: 100%;
  height: 100%;
  background-color: #198754;
}

.sunk {
  margin: auto;
  width: 100%;
  height: 100%;
  background-color: #dc3545;
}

.miss {
  margin: auto;
  width: 100%;
  height: 100%;
  background-color: #0d6efd;
}

.unconfirm {
  margin: auto;
  width: 100%;
  height: 100%;
  background-color: #ffc107;
}

td:hover {
  border: 2px solid #dc3545;
}
</style>
