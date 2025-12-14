const { artifacts, contract, assert, web3 } = require("hardhat")
const { expect } = require("chai")
const escrow = artifacts.require("Escrow")

contract("Escrow", accounts => {
  let Instance;
  before(async () => {
    Instance = await escrow.new()
    console.log("Owner", await Instance.owner())
  })

  it('Should create a order', async () => {
    await Instance.Create("XYZ123", {
      from: accounts[0],
      value: web3.utils.toWei("1", "ether")
    });
    hash = web3.utils.keccak256("XYZ123")
    const order = await Instance.projectId(hash)
    const orderCount = await Instance.orderCount()
    assert.equal(orderCount, 1)
    assert.equal(order.client, accounts[0])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
    assert.equal(order.status, 0)
    assert.equal(order.projectURI, "")
  })

  it('Should accept a order', async () => {
    await Instance.Accept("XYZ123", {
      from: accounts[1]
    });
    hash = web3.utils.keccak256("XYZ123")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 1)
    assert.equal(order.client, accounts[0])
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
  })

  it('Should Complete a order', async () => {
    await Instance.Complete("XYZ123", {
      from: accounts[1]
    });
    hash = web3.utils.keccak256("XYZ123")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 3)
    assert.equal(order.client, accounts[0])
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
  })

  it('Should Release a order', async () => {
    await Instance.Release("XYZ123", {
      from: accounts[0]
    });
    hash = web3.utils.keccak256("XYZ123")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 2)
    assert.equal(order.client, accounts[0])
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount.toString(), '0')
  })

  it('Should create a order again', async () => {
    await Instance.Create("XYZ1234", {
      from: accounts[0],
      value: web3.utils.toWei("1", "ether")
    });
    hash = web3.utils.keccak256("XYZ1234")
    const order = await Instance.projectId(hash)
    const orderCount = await Instance.orderCount()
    assert.equal(orderCount, 2)
    assert.equal(order.client, accounts[0])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
    assert.equal(order.status, 0)
    assert.equal(order.projectURI, "")
  })

  it('Should accept a order again', async () => {
    await Instance.Accept("XYZ1234", {
      from: accounts[1]
    });
    hash = web3.utils.keccak256("XYZ1234")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 1)
    assert.equal(order.client, accounts[0])
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
  })

  it('Should Dispute a order', async () => {
    await Instance.Dispute("XYZ1234", "Didn't fulfill the requirements", {
      from: accounts[0]
    });
    hash = web3.utils.keccak256("XYZ1234")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 4)
    assert.equal(order.client, accounts[0])
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount, web3.utils.toWei("1", "ether"))
  })

  it('Should Resolve a order', async () => {
    await Instance.Resolve("XYZ1234", accounts[1], {
      from: accounts[0]
    });
    hash = web3.utils.keccak256("XYZ1234")
    const order = await Instance.projectId(hash)
    assert.equal(order.status, 5)
    assert.equal(order.client, accounts[0])z
    assert.equal(order.worker, accounts[1])
    assert.equal(order.amount.toString(), '0')
  })


})