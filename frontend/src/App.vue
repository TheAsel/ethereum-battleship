<script setup>
import { RouterView } from 'vue-router'
import { AccountStore } from '@/stores/store'
import { useMetaMaskWallet } from 'vue-connect-wallet'
const address = AccountStore()
const wallet = useMetaMaskWallet()

const connect = async () => {
  const accounts = await wallet.connect()
  if (typeof accounts === 'string') {
    console.log('An error occurred' + accounts)
  }
  address.updateAccount(accounts[0])
}

const switchAccount = async () => {
  await wallet.switchAccounts()
  connect()
}
</script>

<template>
  <nav class="navbar bg-body-tertiary">
    <div class="container-fluid">
      <a class="navbar-brand" href="/">
        <img
          src="./assets/logo.svg"
          alt="Logo"
          width="30"
          height="24"
          class="d-inline-block align-text-top"
        />
        Ethereum Battleship
      </a>
      <form class="d-flex">
        <p v-if="address.getWallet" class="h6 me-4 mt-2">Account: {{ address.getWallet }}</p>
        <button
          v-if="address.getWallet"
          class="btn btn-success"
          type="button"
          @click="switchAccount"
        >
          Change Account
        </button>
        <button v-else class="btn btn-success" type="button" @click="connect">Connect</button>
      </form>
    </div>
  </nav>
  <RouterView />
</template>

<style scoped></style>
