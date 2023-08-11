import HandleGames from '../../build/contracts/HandleGames.json'
import Battleship from '../../build/contracts/Battleship.json'
import Web3 from 'web3'

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

export const showToast = (header, body, type = "text-bg-success") => {
  bootstrap.showToast({
    header: header,
    headerSmall: "just now",
    body: body,
    toastClass: type, // text-bg-[success/warning/danger]
    position: "bottom-0 end-0"
  })
}