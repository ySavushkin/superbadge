@isTest
private class OrderTests {

    @TestSetup
    static void SetupTestData() {
        TestDataFactory.InsertTestData(1);
        insert new Pricebook2(Name = 'Standard Pricebook', IsActive = true);
    }
    
    @isTest
    static void OrderUpdate_UnitTest() {
        List<Product2> productList = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1];
        Product2 product = productList[0];

        List<Order> orderList = [SELECT Id, Status FROM Order LIMIT 1];
        Order order = orderList[0];
        order.Status = Constants.ACTIVATED_ORDER_STATUS;

        Test.startTest();
            update order;
        Test.stopTest();

        Product2 updatedProduct = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :product.Id];
        
        TestDataFactory.VerifyQuantityOrdered(product, updatedProduct, 1);
    }
    
    /**
     * @name orderExtension_UnitTest
     * @description UnitTest for orderExtension
    **/
    @isTest
    static void orderExtension_UnitTest(){
        Test.startTest();
        
        PageReference pageRef = Page.orderEdit;
        Test.setCurrentPage(pageRef);
        Order orderInstance = [SELECT Id FROM Order LIMIT 1];
        ApexPages.StandardController stdCon = new ApexPages.StandardController(orderInstance);
        OrderExtension orderExtension = new OrderExtension(stdCon);
    	
        orderExtension.getFamilyOptions();
		orderExtension.getTotalPages();
        orderExtension.first();
        orderExtension.last();
        orderExtension.next();
        orderExtension.selectFamily();
        orderExtension.onFieldChange();
        orderExtension.save();
        orderExtension.getHasNext();
        orderExtension.getHasPrevious();
        orderExtension.previous();

        Test.stopTest();

        Assert.areEqual(1, orderExtension.GetPageNumber());
        Assert.areEqual(1, orderExtension.GetTotalPages()); 
    }

}