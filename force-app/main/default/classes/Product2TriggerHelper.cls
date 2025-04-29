public class Product2TriggerHelper {

    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('Test ' + Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    public static void afterUpdate(List<Product2> newList, List<Product2> oldList) {
        List<Product2> needsAnnouncementProductList = new List<Product2>();
    
        Map<String, Inventory_Setting__mdt> masterLabelToInventorySettingMetadataMap = Inventory_Setting__mdt.getAll();
    
        for (Product2 productInstance : newList) {
            Inventory_Setting__mdt setting = masterLabelToInventorySettingMetadataMap.get(productInstance.Family);
    
            if (setting != null 
                && productInstance.Quantity_Remaining__c != null 
                && productInstance.Quantity_Remaining__c <= setting.Low_Quantity_Alert__c) {
                
                needsAnnouncementProductList.add(productInstance);
            }
        }
    
        postAlerts(needsAnnouncementProductList);
    }
    
    public static void postAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();

        for ( Product2 p : productList ){
            ConnectApi.AnnouncementInput announcementInput = new ConnectApi.AnnouncementInput();
            announcementInput.expirationDate = Date.today().addDays(1);
            announcementInput.sendEmails = false;
            ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
            textInput.text = p.Name + ', ' + Constants.INVENTORY_LEVEL_LOW;
            bodyInput.messageSegments = new List<ConnectApi.TextSegmentInput>();
            bodyInput.messageSegments.add(textInput);
            announcementInput.body = bodyInput;
            announcementInput.parentId = COLLABORATION_GROUP[0].Id;
           	toPost.add(announcementInput);
        }

        AnnouncementQueueable announcementQueueable = new AnnouncementQueueable();
        announcementQueueable.announcementToPostList = toPost;

        System.enqueueJob(announcementQueueable);
    }
}