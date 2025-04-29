public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<ChartHelper.ChartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
    		orderRecord = queryOrderRecord(orderRecord.Id);
        }
        
        loadStandardController();
        total = 0;
    	for (OrderItem orderItem_i : orderRecord.OrderItems) {
        	orderItemMap.put(orderItem_i.Product2Id, orderItem_i);
        	total += orderItem_i.UnitPrice * orderItem_i.Quantity;
                
        	if(orderItem_i.Quantity > 0) {
                if(pieData == null){
                    pieData = new List<ChartHelper.ChartData>();
                }
            	pieData.add(new ChartHelper.ChartData(orderItem_i.Product2.Name, (orderItem_i.Quantity * orderItem_i.UnitPrice)));
        	}
    	}
		
		populateOrderItems();
    }

    public void loadStandardController() {
        String query = 'SELECT Name, Id, Product2Id, UnitPrice, Product2.Name,Product2.Quantity_Remaining__c, Product2.Family FROM PricebookEntry WHERE isActive= TRUE';
        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE ) {
            query += ' AND Product2.Family = \''+ selectedFamily + '\'';
        }
        
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

    public void populateOrderItems() {
        orderItemList = new List<OrderItem>();
        
        for(SObject sObject_i : standardSetController.getRecords()) {
            PricebookEntry pricebookEntryInstance = (PricebookEntry) sObject_i;
            
            if(orderItemMap.containsKey(pricebookEntryInstance.Product2Id)) {
                orderItemList.add(orderItemMap.get(pricebookEntryInstance.Product2Id));
            } else {
                OrderItem orderItem = new OrderItem(
                	PricebookEntryId = pricebookEntryInstance.Id,
                    Product2Id = pricebookEntryInstance.Product2Id,
                    UnitPrice = pricebookEntryInstance.UnitPrice,
                    Quantity = 0,
                    Product2 = pricebookEntryInstance.Product2
                );
                orderItemList.add(orderItem);
                orderItemMap.put(pricebookEntryInstance.Product2Id, orderItem);
            } 
        }
    }

    public void OnFieldChange(){ 
        for(OrderItem orderItem : orderItemList) {
            orderItemMap.put(orderItem.Product2Id, orderItem);
        }
        pieData = new List<ChartHelper.ChartData>();
    	total = 0;
        
        for (OrderItem orderItem : orderItemList) {
        	orderItemMap.put(orderItem.Product2Id, orderItem);
        	total += orderItem.UnitPrice * orderItem.Quantity;
            
            if(orderItem.Quantity > 0) {
                pieData.add(new ChartHelper.ChartData(orderItem.Product2.Name, (orderItem.Quantity * orderItem.UnitPrice)));
            }
    	}
    }

    public void selectFamily(){
        loadStandardController();
        PopulateOrderItems();
    }

    public void save(){
        System.Savepoint sp = Database.setSavepoint();
        
        try {
            if (orderRecord.Pricebook2Id == null) {
            	orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        	}
        	upsert orderRecord;
        	List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
        	List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        	for (OrderItem orderItem : orderItemList) {
        		if (orderItem.Quantity > 0) {
            		if (orderItem.OrderId == null) {
                    	orderItem.OrderId = orderRecord.Id;
                	}
                	orderItemsToUpsert.add(orderItem);
            	} else if (orderItem.Id != null) {
                	orderItemsToDelete.add(orderItem);
            	}
        	}
       		upsert orderItemsToUpsert;
       		delete orderItemsToDelete;
        } catch (Exception ex) {
            Database.rollback(sp);
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
    }

    public void first(){
		standardSetController.first();
        PopulateOrderItems();
    }

    public void next(){
		standardSetController.next();
        PopulateOrderItems();
    }

    public void previous(){
		standardSetController.previous();
        PopulateOrderItems();
    }

    public void last(){
		standardSetController.last();
        PopulateOrderItems();
    }

    public Boolean getHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    public Boolean getHasNext(){
        return standardSetController.getHasNext();
    }

    public Integer getTotalPages(){
        return (Integer) Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    public Integer getPageNumber(){
        return standardSetController.getPageNumber();
    }

    public List<SelectOption> getFamilyOptions(){
    	List<SelectOption> optionList = new List<SelectOption>();
    	optionList.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    
    	for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            optionList.add(new SelectOption(entry.getValue(), entry.getLabel()));
    	}
        
    	return optionList;
	}

    public static Order queryOrderRecord(Id orderId){
        return [
            SELECT Id
            , AccountId
            , EffectiveDate
            , Name
            , Status
            , Pricebook2Id
            , (SELECT Id
                , OrderId
                , Quantity
                , UnitPrice
                , PricebookEntryId
                , Product2Id
                , Product2.Name
                , Product2.Family
                , Product2.Quantity_Remaining__c
              FROM OrderItems)
            FROM Order
            WHERE Id = :orderId
        ];
    }
}