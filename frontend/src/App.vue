<script setup>
import { RouterView } from 'vue-router'
import { AccountStore, HandleGamesContract, BattleshipContract } from '@/stores/store'
import { useMetaMaskWallet } from 'vue-connect-wallet'
import HandleGames from '../../build/contracts/HandleGames.json'
import Battleship from '../../build/contracts/Battleship.json'
import Web3 from 'web3'
const address = AccountStore()
const handleGamesContract = HandleGamesContract()
const battleshipContract = BattleshipContract()
const wallet = useMetaMaskWallet()

const connect = async () => {
  const accounts = await wallet.connect()
  if (typeof accounts === 'string') {
    console.log('An error occurred' + accounts)
  }
  address.updateAccount(accounts[0])
  contractHandleGames()
  // contractBattleship()
}

const switchAccount = async () => {
  await wallet.switchAccounts()
  connect()
}

const contractHandleGames = async () => {
  let web3 = new Web3(window.ethereum)
  const networkID = await web3.eth.net.getId()
  const { abi } = HandleGames
  const contractAddress = HandleGames.networks[networkID].address
  const contract = new web3.eth.Contract(abi, contractAddress)
  handleGamesContract.updateContract(contract)
}

const contractBattleship = async () => {
  let web3 = new Web3(window.ethereum)
  const networkID = await web3.eth.net.getId()
  const { abi } = Battleship
  const contractAddress = Battleship.networks[networkID].address
  const contract = new web3.eth.Contract(abi, contractAddress)
  battleshipContract.updateContract(contract)
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
