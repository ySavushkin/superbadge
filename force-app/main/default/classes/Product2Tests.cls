@isTest(seeAllData=true)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for Product2Extension
    **/
    @isTest
    static void product2Extension_UnitTest() {
        Test.startTest();
        
        PageReference pageRef = Page.product2New;
        Test.setCurrentPage(pageRef);
        Product2 productInstance = new Product2(Name = 'Test', IsActive = true);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(productInstance);
        Product2Extension productExtension = new Product2Extension(stdCon);
        productExtension.addRows(); 

        System.assertEquals(Constants.DEFAULT_ROWS * 2, productExtension.productsToInsert.size());

        for (Integer i = 0; i < 5; i++) {
            Product2Extension.ProductWrapper wrapper = productExtension.productsToInsert[i];
            Product2 pro = new Product2(
                Name = 'Test Product' + i,
                IsActive = true,
                Initial_Inventory__c = 20,
                Family = Constants.PRODUCT_FAMILY[0].getValue()
            );
            wrapper.productRecord = pro;
            
            PricebookEntry pbe = new PricebookEntry(
                IsActive = true,
                UnitPrice = 10
            );
            wrapper.pricebookEntryRecord = pbe;
        }
        
        productExtension.save();
        productExtension.getFamilyOptions();
        productExtension.getInventory();

        Test.stopTest();
        
        List<Product2> createdProducts = [
            SELECT Id FROM Product2 WHERE IsActive = true AND Name = 'Test Product1'
        ];
        
        System.assertEquals(1, createdProducts.size());
    }

    /**
     * @name product2Trigger_UnitTest
     * @description UnitTest for Product2 Trigger Logic
    **/
    @isTest
    static void product2Trigger_UnitTest() {
        
        Product2 newProduct = new Product2(
            Name = 'Test',
            Family = 'Dessert',
            IsActive = true,
            Quantity_Ordered__c = 5,
            Initial_Inventory__c = 10
        );
        insert newProduct;
        
        CollaborationGroup collaborationGroup = new CollaborationGroup(
            Name = 'Test ' + Constants.INVENTORY_ANNOUNCEMENTS,
            Description = 'Description',
            CollaborationType = 'Public'
        );
        insert collaborationGroup;
        
        newProduct.Quantity_Ordered__c = 50;

        Test.startTest();
        update newProduct;
        Test.stopTest();
    }
}
