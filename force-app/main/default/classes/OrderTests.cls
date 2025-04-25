@IsTest
private class OrderTests {

    @TestSetup
    static void SetupTestData() {
        TestDataFactory.InsertTestData(1);
    }
    
    @IsTest
    static void OrderUpdate_UnitTest() {
        List<Product2> productList = [SELECT Id, Quantity_Ordered__c FROM Product2];
        Product2 product = productList[0];

        List<Order> orderList = [SELECT Id, Status FROM Order];
        Order order = orderList[0];
        order.Status = Constants.ACTIVATED_ORDER_STATUS;

        update order;

        Product2 updatedProduct = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :product.Id];
        
        TestDataFactory.VerifyQuantityOrdered(product, updatedProduct, 1);
    }
    
    /**
     * @name orderExtension_UnitTest
     * @description UnitTest for orderExtension
    **/
    static TestMethod void orderExtension_UnitTest(){
        Test.startTest();
        
        PageReference pageRef = Page.orderEdit;
        Test.setCurrentPage(pageRef);
        Order orderInstance = [SELECT Id FROM Order LIMIT 1];
        ApexPages.StandardController stdCon = new ApexPages.StandardController(orderInstance);
        OrderExtension orderExtension = new OrderExtension(stdCon);
    	
        orderExtension.GetFamilyOptions();
		orderExtension.GetTotalPages();
        orderExtension.First();
        orderExtension.Last();
        orderExtension.Next();
        orderExtension.SelectFamily();
        orderExtension.OnFieldChange();
        orderExtension.Save();
        orderExtension.GetHasNext();
        orderExtension.GetHasPrevious();
        orderExtension.Previous();

        Assert.areEqual(1, orderExtension.GetPageNumber());
        Assert.areEqual(1, orderExtension.GetTotalPages()); 
        Test.stopTest();
    }

}