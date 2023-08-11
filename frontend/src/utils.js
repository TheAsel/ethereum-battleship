import HandleGames from '../../build/contracts/HandleGames.json'
import Battleship from '../../build/contracts/Battleship.json'
import Web3 from 'web3'
import { useMetaMaskWallet } from 'vue-connect-wallet'
const wallet = useMetaMaskWallet()

export const isConnected = async () => {
  const accounts = await wallet.getAccounts()
  if (typeof accounts === 'string') return false
  return accounts.length > 0
}

export const getEthAccounts = async () => {
  let web3 = new Web3(window.ethereum)
  return await web3.eth.getAccounts()
}

export const contractHandleGames = async () => {
  let web3 = new Web3(window.ethereum)
  const networkID = await web3.eth.net.getId()
  const { abi } = HandleGames
  const contractAddress = HandleGames.networks[networkID].address
  return new web3.eth.Contract(abi, contractAddress)
}

export const contractBattleship = async () => {
  let web3 = new Web3(window.ethereum)
  const networkID = await web3.eth.net.getId()
  const { abi } = Battleship
  const contractAddress = Battleship.networks[networkID].address
  return new web3.eth.Contract(abi, contractAddress)
}

export const showToast = (header = '', body = '', type = 'text-bg-success') => {
  bootstrap.showToast({
    header: header,
    headerSmall: 'just now',
    body: body,
    toastClass: type, // text-bg-[success/warning/danger]
    position: 'bottom-0 end-0'
  })
}
