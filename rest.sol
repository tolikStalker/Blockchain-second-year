// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.12;

contract Restaraunt {
    enum Status {   // Статус заказа
        order,
        cooking,
        completed
    }

    struct Dish {   // Структура блюда
        uint16 price;   // Цена блюда
        string name;    // Название блюда
    }

    struct Order {  // Структура заказа
        Dish[] dishes;  // Заказанные блюда
        uint64 price;   // Общая цена
        uint time;      // Время заказа
        uint tableIndex;// Номер занятого столика
        address payable customer;
        Status status;
    }

    Order[] orders;
    Dish[] dish;    // Список всех блюд
    bool[] tables;  // Список столиков
    address payable public Owner;   // Адрес владельца
    uint completedNumber = 0;

    // Очистить заказ
    function clearOrder(uint16 index) public {
        orders[index].price = 0;
        delete orders[index].dishes;
        orders[index].status = Status.order;
    }

    // Удалить заказ из очереди
    function delFromQueue() public {
        require(orders[completedNumber].status == Status.cooking, "Order queue is empty.");
        orders[completedNumber++].status = Status.completed;
    }

    // Начало оформления заказа
    function startOrder() public {
        orders.push();
        orders[orders.length - 1].customer = payable(msg.sender);
        orders[orders.length - 1].status = Status.order;
    }

    // Вычисление скидки
    function calcDiscount(uint256 _price) internal pure returns (uint256) {
        if(_price > 500)
            return _price * 85 / 100;
        if(_price > 200)
            return _price * 90 / 100;
        if(_price > 100)
            return _price * 95 / 100;
        return _price;
    }

    constructor()  { 
        Owner = payable(msg.sender); 
        completedNumber = 0;
    }

    // Установить необходимое количество столиков
    function setTableCount(uint16 num) public {
        require(msg.sender == Owner, "Not owner"); 
        if(num > tables.length)
            for(uint i = tables.length; i < num; i++)
                tables.push(false);
        else
            for(uint i = tables.length; i > num; i--)
                tables.pop();
    }

    // Заказать столик
    function orderTable(uint index, uint16 orderIndex) public {
        require(tables[index] == false, "The table is occupied.");
        tables[index] = true;
        orders[orderIndex].tableIndex = index;
    }

    // Освободить столик
    function freeTable(uint index) internal {
        require(tables[index] == true, "The table is already free.");
        tables[index] = false;
    }

    // Получить список столиков
    function getTableList() public view returns(bool[] memory) {
        return tables;
    }

    // Получить меню
    function getDishList() public view returns(Dish[] memory) {
        return dish;
    }

    // Поменять блюдо в меню
    function setDish(uint16 _index, uint16 _price, string memory _name) public {
        require(msg.sender == Owner, "Not owner"); 
        require(_index < dish.length, "This dish index is not exist.");
        dish[_index] = Dish(_price, _name);
    }

    // Добавить блюдо в меню
    function addDish(uint16 _price, string memory _name) public {
        require(msg.sender == Owner, "Not owner"); 
        dish.push(Dish(_price, _name));
    }

    function getOrders() public view returns(Order[] memory){
        return orders;
    }

    // Добавить блюдо в заказ
    function addDishToOrder(uint16 _dishIndex, uint16 _orderIndex) public {
        require(_dishIndex < dish.length, "This dish index is not exist.");
        orders[_orderIndex].price += dish[_dishIndex].price;
        orders[_orderIndex].dishes.push(dish[_dishIndex]);
    }

    // Удалить блюдо из заказа
    function delDishFromOrder(uint16 _dishIndex, uint16 _orderIndex) public {
        require(_dishIndex < orders[_orderIndex].dishes.length, "This dish index is not exist.");
        orders[_orderIndex].price -= orders[_orderIndex].dishes[_dishIndex].price;
        delete orders[_orderIndex].dishes[_dishIndex];
    }

    // Получить итоговую цену заказа
    function getPrice(uint16 _orderIndex) public view returns(uint64) {
        return orders[_orderIndex].price;
    }

    // Получить итоговую цену заказа со скидкой
    function getDiscountPrice(uint16 _orderIndex) public view returns(uint256) {
        return calcDiscount(orders[_orderIndex].price);
    }

    // Добавить заказ в очередь
    function toQueue(uint16 _orderIndex) public {
        require(tables[orders[_orderIndex].tableIndex] == true, "This table is not ordered.");
        require(orders[_orderIndex].status == Status.order, "Order already cooking.");
        require(orders[_orderIndex].price > 0, "Order is empty.");
        orders[_orderIndex].time = block.timestamp;
        orders[_orderIndex].status = Status.cooking;
    }

    // Оплата заказа
    function buy(uint16 _orderIndex) public payable { 
        require(orders[_orderIndex].status == Status.completed, "Order is not completed yet.");
        Owner.transfer(msg.value);
        freeTable(orders[_orderIndex].tableIndex);
        clearOrder(_orderIndex);
    }
}