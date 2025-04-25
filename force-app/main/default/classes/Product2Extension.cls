public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    
    public Product2Extension() {}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i < Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();

        try {
            List<Product2> productList = new List<Product2>();
            List<PricebookEntry> entryList = new List<PricebookEntry>();

            for (ProductWrapper productWrapper : productsToInsert){
                if(productWrapper.productRecord != null && productWrapper.pricebookEntryRecord != null){
                    if(productWrapper.productRecord.Name != null 
                       && productWrapper.productRecord.Family != null 
                       && productWrapper.productRecord.Family != Constants.SELECT_ONE 
                       && productWrapper.productRecord.Initial_Inventory__c != null 
                       && productWrapper.pricebookEntryRecord.UnitPrice != null){
                        
                        productList.add(productWrapper.productRecord);
                           
                        PricebookEntry entry = productWrapper.pricebookEntryRecord;
                        entry.IsActive = true;
                        entry.Pricebook2Id = constants.STANDARD_PRICEBOOK_ID;

                        entryList.add(entry);  
                    }

                }

            }

            insert productList; 
             
            for (Integer i = 0; i < entryList.size();i++){
                entryList[i].Product2Id = productList[i].id;
            }

            insert entryList;

            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, productsToInsert.size() + 'Inserted'));
            productsToInsert.clear();
            addRows();

        } catch (Exception e){
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }

        return null;
    }
    
    public List<SelectOption> GetFamilyOptions(){
    	List<SelectOption> optionList = new List<SelectOption>();
    	optionList.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    
    	for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            optionList.add(new SelectOption(entry.getValue(), entry.getLabel()));
    	}
        
    	return optionList;
	}

    public class ProductWrapper {
        public Product2 productRecord { get; set; }
        public PriceBookEntry pricebookEntryRecord { get; set; }
        
        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PricebookEntry(Unitprice = 0.0);
        }
    }  
}