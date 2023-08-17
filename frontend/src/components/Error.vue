<script setup>
import { RouterLink } from 'vue-router'
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
            <div class="col text-center">
              <h3>Whoops! Something went wrong...</h3>
            </div>
          </form>
          <RouterLink class="btn btn-success" type="button" to="/">Back to Homepage</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>
