<script setup>
import { RouterView } from 'vue-router'
import { AccountStore } from '@/stores/store'
import { useMetaMaskWallet } from 'vue-connect-wallet'
import { isConnected, showToast } from '@/utils'

const address = AccountStore()
const wallet = useMetaMaskWallet()

const connect = async () => {
  try {
    const accounts = await wallet.connect()
    if (typeof accounts === 'string') {
      showToast('Error', "Couldn't connect to MetaMask")
    } else {
      address.updateAccount(accounts[0])
      showToast('Connected', 'Successfully connected to your MetaMask account', 'text-bg-success')
    }
  } catch (err) {
    showToast('Error', err.message)
  }
}

const switchAccount = async () => {
  await wallet.switchAccounts()
  connect()
}

if (isConnected) {
  connect()
}
</script>

<template>
  <nav class="navbar bg-body-tertiary">
    <div class="container-fluid">
      <a class="navbar-brand" href="/">
        <img
          src="@/assets/logo.svg"
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
  <Suspense>
    <RouterView />
  </Suspense>
</template>

<style scoped></style>
