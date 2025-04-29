/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable{

    public List<ConnectApi.AnnouncementInput> announcementToPostList;

	public void execute(QueueableContext context) {
        postAnnouncements(announcementToPostList);       
    }

    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public static void postAnnouncements(List<ConnectApi.AnnouncementInput> announcementList){
        while ( announcementList.size() > 0 ){
            if ( Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest() ){
                ConnectApi.AnnouncementInput announcement = announcementList.remove(0);
                ConnectApi.Announcements.postAnnouncement(Constants.INTERNAL_INVENTORY_ANNOUNCEMENT, announcement);
            } else {
                break;
            }
        }
        if ( announcementList.size() > 0 && !test.isRunningTest() ){
            AnnouncementQueueable announcementQueue  = new AnnouncementQueueable();
            announcementQueue .announcementToPostList = announcementList;

            System.enqueueJob(announcementQueue );
        }
    }

}