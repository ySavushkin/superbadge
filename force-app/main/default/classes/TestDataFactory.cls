public with sharing class TestDataFactory {

    public static CollaborationGroup constructCollaborationGroup(){
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Test '+ Constants.INVENTORY_ANNOUNCEMENTS,  
            CollaborationType = 'Public'
        );
        return chatterGroup;
    }

    public static List<Product2> constructProducts(Integer cnt){
        List<Product2> productList = new List<Product2>();
        
        for(Integer i = 0; i < cnt; i++){
            productList.add(new Product2(
            	Name = 'Test Product ' + i,
				IsActive = true,
                Initial_Inventory__c = 10,
                Family = Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue()
            ));
        }
        
        return productList;
    }

    public static List<PricebookEntry> constructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        
        for(Integer i = 0; i < prods.size(); i++){
            pricebookEntryList.add(new PricebookEntry(
            	Product2Id = prods[i].Id,
                UnitPrice = 10 + (i * 10),
                IsActive = true,
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID
            ));
        }
        
        return pricebookEntryList;
    }

    public static List<Account> constructAccounts(Integer cnt){
        List<Account> accountList = new List<Account>();
        
        for(Integer i = 0; i < cnt; i++) {
        	accountList.add(new Account(
            	Name = 'Test Account ' + i
            ));
        }
        
        return accountList;
    }

    public static List<Contact> constructContacts(Integer cnt, List<Account> accts){
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i = 0; i < cnt; i++) {
            contactList.add(new Contact(
            	FirstName = 'Test',
            	LastName = 'Contact ' + i,
            	AccountId = accts.get(Math.mod(i, accts.size())).Id
            ));            
        }
        
        return contactList;
    }

    public static List<Order> constructOrders(Integer cnt, List<Account> accts){
		List<Order> orderList = new List<Order>();
        
        for(Integer i = 0; i < cnt; i++) {
            orderList.add(new Order(
            	AccountId = accts.get(math.mod(i, accts.size())).Id,
                Name = 'Test order ' + i,
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                Status='Draft',
                EffectiveDate = System.today()
            ));
        }
        
        return orderList;
    }

    public static List<OrderItem> constructOrderItems(Integer cnt, List<PriceBookEntry> priceBookEntryList, List<Order> orderList){
        List<OrderItem> orderItemList = new List<OrderItem>();
        
        for(Integer i = 0; i < cnt; i++) {
            orderItemList.add(new OrderItem(
            	PricebookEntryId = priceBookEntryList.get(math.mod(i, priceBookEntryList.size())).Id,
                OrderId = orderList.get(math.mod(i, orderList.size())).Id,
                Quantity = 1,
                UnitPrice = 10 + (i * 10)
            ));
        }
        
        return orderItemList;
    }

    public static void insertTestData(Integer cnt){

		CollaborationGroup collaborationGroup = TestDataFactory.constructCollaborationGroup();
        insert collaborationGroup;
        
        List<Product2> productList = TestDataFactory.constructProducts(cnt);
        insert productList;
        
        List<PriceBookEntry> pricebookEntryList = TestDataFactory.constructPricebookEntries(productList);
        insert pricebookEntryList;
        
        List<Account> accountList = TestDataFactory.constructAccounts(cnt);
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.constructContacts(cnt, accountList);
        insert contactList;
        
        List<Order> orderList = TestDataFactory.constructOrders(cnt, accountList);
        insert orderList;
        
        List<OrderItem> orderItemList = TestDataFactory.constructOrderItems(cnt, pricebookEntryList, orderList);
        insert orderItemList;
    }
    
    public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer quantityOrdered) {
        Assert.areEqual((updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c), quantityOrdered);
    }

}