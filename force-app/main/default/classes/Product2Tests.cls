@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
        
        PageReference pageRef = Page.product2New;
        Test.setCurrentPage(pageRef);
        Product2 productInstance = new Product2(name = 'Test', isActive = true);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(productInstance);
        Product2Extension productExtension = new Product2Extension(stdCon);
    	productExtension.addRows(); 

        Assert.areEqual(productExtension.productsToInsert.size(), Constants.DEFAULT_ROWS*2);

        for (Integer i = 0; i < 5; i++) {
            Product2Extension.ProductWrapper wrapper = productExtension.productsToInsert[i];
            Product2 pro = new Product2();
            pro.Name = 'Test Product' + i;
            pro.IsActive = true;
            pro.Initial_Inventory__c = 20;
            pro.Family = Constants.PRODUCT_FAMILY[0].getValue();
            wrapper.productRecord = pro;
            
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.IsActive = true;
            pbe.UnitPrice = 10;
            wrapper.pricebookEntryRecord =pbe;
            
        }
        
        productExtension.save();
        productExtension.GetFamilyOptions();
        productExtension.GetInventory();
        Test.stopTest();
        
        List<Product2> createdProducts = [
            SELECT Id FROM Product2 WHERE IsActive= true AND Name = 'Test Product1'
        ];
        
        System.assertEquals(1, createdProducts.size());
    }
    
    static TestMethod void Product2Trigger_UnitTest() {
        Test.startTest();
        Product2 newProduct = new Product2();
        newProduct.Name = 'Test';
        newProduct.Family = 'Dessert';
        newProduct.IsActive = true;
        newProduct.Quantity_Ordered__c = 5;
        newProduct.Initial_Inventory__c = 10;
        insert newProduct;
        
        CollaborationGroup c = new CollaborationGroup();
        c.Name = 'Test ' + Constants.INVENTORY_ANNOUNCEMENTS;
        c.Description = 'Description';
        c.CollaborationType = 'Public';
        insert c;
        
        newProduct.Quantity_Ordered__c = 50;
        update newProduct;
        Test.stopTest();
    }

}