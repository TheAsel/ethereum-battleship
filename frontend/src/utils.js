import HandleGames from '../../build/contracts/HandleGames.json'
import Battleship from '../../build/contracts/Battleship.json'
import Web3 from 'web3'
import { useMetaMaskWallet } from 'vue-connect-wallet'

const wallet = useMetaMaskWallet()

export const BOARD_SIDE = 8
export const BOARD_SIZE = BOARD_SIDE * BOARD_SIDE
export const SHIP_COUNT = 10

export const isConnected = async () => {
  const accounts = await wallet.getAccounts()
  if (typeof accounts === 'string') return false
  return accounts.length > 0
}

export const getEthAccounts = async () => {
  try {
    let web3 = new Web3(window.ethereum)
    return await web3.eth.getAccounts()
  } catch (err) {
    showToast('Error', err.message, 'text-bg-danger')
  }
}

export const contractHandleGames = async () => {
  let web3 = new Web3(window.ethereum)
  const networkID = await web3.eth.net.getId()
  const { abi } = HandleGames
  const contractAddress = HandleGames.networks[networkID].address
  return new web3.eth.Contract(abi, contractAddress)
}

export const contractBattleship = (address) => {
  let web3 = new Web3(window.ethereum)
  const { abi } = Battleship
  return new web3.eth.Contract(abi, address)
}

export const showToast = (header = '', body = '', type = 'text-bg-danger') => {
  const duplicates = Array.from(document.querySelectorAll('.toast-body')).filter((h) =>
    h.textContent.includes(body)
  )
  if (typeof duplicates != 'undefined') {
    for (let i = 0; i < duplicates.length; i++) {
      duplicates[i].parentElement.parentElement.remove()
    }
  }
  bootstrap.showToast({
    header: header,
    headerSmall: 'just now',
    body: body,
    toastClass: type, // text-bg-[success/warning/danger]
    position: 'bottom-0 end-0'
  })
}
