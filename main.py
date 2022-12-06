import web3
import json


class Restaurant:
    with open("abi.json", "r") as file:
        abi = json.load(file)

    def __init__(self, contract_address, admin_address, url):
        self.mapIndex = []
        self.w3 = web3.Web3(web3.HTTPProvider(url))
        self.w3.eth.default_account = admin_address
        self.contract_address = web3.Web3.toChecksumAddress(contract_address)
        self.contract = self.w3.eth.contract(address=contract_address, abi=self.abi)

    def accounts(self):
        return self.w3.eth.accounts

    def get_balance(self, address):
        address = web3.Web3.toChecksumAddress(address)
        return web3.Web3.fromWei(self.w3.eth.getBalance(address), "ether")

    def get_table_list(self):
        return self.contract.functions.getTableList().call()

    def get_price(self, order_index):
        return self.contract.functions.getPrice(order_index).call()

    def get_orders(self):
        return self.contract.functions.getOrders().call()

    def get_dish_list(self):
        return self.contract.functions.getDishList().call()

    def get_discount_price(self, order_index):
        return self.contract.functions.getDiscountPrice(order_index).call()

    def to_queue(self, order_index):
        self.contract.functions.toQueue(order_index).transact({'from': self.mapIndex[order_index]})

    def add_dish(self, price, name):
        self.contract.functions.addDish(price, name).transact({'from': self.w3.eth.default_account})

    def start_order(self, address):
        self.mapIndex.append(address)
        self.contract.functions.startOrder().transact({'from': address})

    def order_table(self, table_index, order_index):
        self.contract.functions.orderTable(table_index, order_index).transact({'from': self.mapIndex[order_index]})

    def add_dish_to_order(self, dish_index, order_index):
        self.contract.functions.addDishToOrder(dish_index, order_index).transact({'from': self.mapIndex[order_index]})

    def del_dish_from_order(self, dish_index, order_index):
        self.contract.functions.delDishFromOrder(dish_index, order_index).transact({'from': self.mapIndex[order_index]})

    def clear_order(self, order_index):
        self.contract.functions.clearOrder(order_index).transact({'from': self.mapIndex[order_index]})

    def del_from_queue(self):
        self.contract.functions.delFromQueue().transact({'from': self.w3.eth.default_account})

    def set_table_count(self, number):
        self.contract.functions.setTableCount(number).transact({'from': self.w3.eth.default_account})

    def buy(self, order_index):
        self.contract.functions.buy(order_index).transact({'from': self.mapIndex[order_index],
                                                           "value": self.get_discount_price(order_index)})


customer1 = '0x9937b07C5A84342b35c5968AFc1d0d2Aaaa0AAA3'
customer2 = '0xCa5e153e11926934B36bb2e325dEbBe3a27aCa76'
rest = Restaurant('0xDC7cF48a4b64D3202C88bAf8D9406DA33EE46153',
                  '0x5F7D5F6afF27a2B5a9F18D39E06B40dd0D9A579D',
                  "HTTP://127.0.0.1:8545")
acc = rest.accounts()
print(acc)
rest.add_dish(10000000, 'soup')
rest.add_dish(20000000, 'cake')
rest.add_dish(70000000, 'egg')
rest.set_table_count(5)
print(rest.get_dish_list())
print(rest.get_table_list())
index = 0
rest.start_order(customer1)
rest.order_table(0, index)
rest.add_dish_to_order(0, index)
rest.add_dish_to_order(1, index)
rest.to_queue(index)
print(rest.get_orders())
rest.del_from_queue()
rest.buy(index)
