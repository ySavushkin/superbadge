public without sharing class OrderTriggerHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void afterUpdate(Map<Id, Order> newMap, Map<Id, Order> oldMap){
        Set<Id> orderIdSet = new Set<Id>();

        for (Id orderId : newMap.keySet()) {
            Order newOrder = newMap.get(orderId);
            Order oldOrder = oldMap.get(orderId);
        
            if (checkOrderStatus(newOrder, oldOrder)) {
                orderIdSet.add(orderId);
            }
        }
        
       rollUpOrderItems(orderIdSet);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void rollUpOrderItems(Set<Id> activatedOrderIdSet){
        Map<Id, Product2> productMap = getProduct2MapByOrderIds(activatedOrderIdSet);
    
        if (productMap.isEmpty()) {
            return;
        }
    
        Map<Id, Decimal> quantityByProduct = getProductQuantity(productMap.keySet());
    
        for (Id productId : quantityByProduct.keySet()) {
            productMap.get(productId).Quantity_Ordered__c = quantityByProduct.get(productId);
        }
    
        update productMap.values();
    }    

    public static Boolean checkOrderStatus(Order newOrder, Order oldOrder) {
        return newOrder.Status != null 
            && oldOrder.Status != null 
            && newOrder.Status == Constants.ACTIVATED_ORDER_STATUS 
            && oldOrder.Status != Constants.ACTIVATED_ORDER_STATUS;
    }

    private static Map<Id, Product2> getProduct2MapByOrderIds(Set<Id> orderIds) {
        Map<Id, Product2> productMap = new Map<Id, Product2>();
    
        for (OrderItem orderItem : [
            SELECT Product2Id 
            FROM OrderItem 
            WHERE OrderId IN :orderIds
        ]) {
            if (!productMap.containsKey(orderItem.Product2Id)) {
                productMap.put(orderItem.Product2Id, new Product2(
                    Id = orderItem.Product2Id,
                    Quantity_Ordered__c = 0
                ));
            }
        }
    
        return productMap;
    }

    private static Map<Id, Decimal> getProductQuantity(Set<Id> productIds) {
        Map<Id, Decimal> result = new Map<Id, Decimal>();
    
        for (AggregateResult ar : [
            SELECT Product2Id
            , SUM(Quantity) Quantity 
            FROM OrderItem 
            WHERE Product2Id IN :productIds 
            GROUP BY Product2Id
        ]) {
            result.put((Id)ar.get('Product2Id'), (Decimal)ar.get('Quantity'));
        }
    
        return result;
    }
}